$invocation = (Get-Variable MyInvocation).Value
$scriptHome = Split-Path $invocation.MyCommand.Path

$path = "C:\dev\svn\Solutions\Class Libraries";
$pathSpec = $path + "\*";
$targetPath = "C:\dev\git-svn\Class Libraries";

function CopyFiles($target, $destination) 
{
    Write-Host Copying from "$target" to "$destination"

	New-Item $destination -ItemType Directory -ErrorAction SilentlyContinue; 
	robocopy $target $destination /E
}

function CreateGitRepository($repoName, $newPath)
{
	$gitRepoName = $repoName.Replace(" ", "-").Replace($targetPath, "").ToLower();
		
	cd $newPath
	git init
	git add .
	git commit -m "Import"
	git remote add origin ssh://git@stash.euromoneydigital.com:7999/class/$gitRepoName.git

	cd $scriptHome
}

function CreateNuSpec($destination)
{
	echo "Creating NuSpec"
	echo "Finding project files in $destination"
	
	# Create NuSpecs and Package commands
	Get-ChildItem -Path $destination -Filter "*proj" -Recurse | ForEach-Object { 
		$pathToProj = $_.FullName.Replace($_.Name, "");
		$nameStem = $_.Name.Replace(".csproj", "").Replace(".vbproj", "");
		$extension = $_.Name.Replace("$nameStem", "");
		$relativePath = $pathToProj.Replace($destination + "\", "");
		
		xcopy "$scriptHome\template.nuspec" "$pathToProj" /Y /F
		Rename-Item "$pathToProj\template.nuspec" "$nameStem.nuspec"
		
		$packPath = "$relativePath$nameStem$extension";
		$packOpts = "-OutputDirectory artifacts -Build -IncludeReferencedProjects -NonInteractive"
		
		Add-Content "$destination\package.cmd" ".nuget\nuget pack $packPath $packOpts"

		echo "Created $pathToProj"
	}
	
	# Create build script
	Get-ChildItem -Path $destination -Filter "*sln" -Recurse | ForEach-Object { 
		$msb = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe /m:8 /p:Configuration=Release "
		Add-Content "$destination\build.cmd" "$msb $_"
	}
}
function MapExternalDependencies($destination)
{
	echo "Scanning for dependencies in $destination"    
    $depPath = "C:\dev\svn\External Dependencies";

    $projectFiles = get-childitem "$destination" -include *proj -rec;

    foreach($project in $projectFiles) 
    {
        $dependant = "False";

        $matches = $project | select-string -Pattern "External Dependencies";
        foreach($match in $matches)
        {
            if($dependant -eq "False"){
                Write-Host $project.Name
                $dependant = "True";
            }

            $dep = ($match.Line -replace "^.+\\External Dependencies", "").Replace("</HintPath>", "").trim();
            $fullDep = "$depPath$dep";

            Write-Host Requires $fullDep
            echo f | xcopy /f /y $fullDep "$destination\lib$dep"

		    $content = gc $match.Path;
		    $updatedContent = ($content -replace "^.+\\External Dependencies", "<HintPath>..\lib");	    
            sc $match.Path $updatedContent;
        }	
	}
}

function InstallNuGetCli($destination)
{
	robocopy "$scriptHome\layout" "$destination" /E /NFL /NDL /NJH /NJS
}

function Build()
{
	echo "Build time!"
	Get-ChildItem -Path $targetPath -Filter "build.cmd" -Recurse | ForEach-Object { 
			$pathToProj = $_.FullName.Replace($_.Name, "");
			$relativePath = $pathToProj.Replace($destination + "\", "");
			
			cd $pathToProj
			cmd /c "$pathToProj\build.cmd"
	}
}

Get-ChildItem $pathSpec | ForEach-Object { 
	if ($_.FullName -eq "git-migrate.ps1"){
		continue
	}

	$newPath = $_.FullName.Replace($path, $targetPath);  

	CopyFiles "$_" "$newPath";
	CreateNuSpec $newPath;
	InstallNuGetCli $newPath;
	MapExternalDependencies $newPath;
	CreateGitRepository $_.Name "$newPath";
	
	# Debug - exit after first directory
	#exit 1;
}

# Build();
