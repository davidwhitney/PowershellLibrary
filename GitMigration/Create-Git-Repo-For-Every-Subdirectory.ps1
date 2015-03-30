# Get-ChildItem -Recurse | ?{ $_.PSIsContainer } | ForEach-Object {   

$invocation = (Get-Variable MyInvocation).Value
$scriptHome = Split-Path $invocation.MyCommand.Path

$path = "C:\dev\svn\Solutions\Class Libraries";
$pathSpec = $path + "\*";
$targetPath = "C:\dev\git-svn\Class Libraries";

function CopyFiles($target, $destination) 
{
	New-Item $newPath -ItemType Directory -ErrorAction SilentlyContinue; 
	robocopy $target $destination /E
}

function CreateGitRepository($repoName, $directory)
{
	$gitRepoName = $repoName.Replace(" ", "-");
		
	cd $newPath
	git init
	git add .
	git commit -m "Import"
	git remote add origin ssh://git@stash.euromoneydigital.com:7999/winapps/$gitRepoName.git

	cd $scriptHome
}

function CreateNuSpec($destination)
{
	echo "Creating NuSpec"
	echo "Finding project files in $destination"
	
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
}

function InstallNuGetCli($destination)
{
	robocopy "$scriptHome\layout" "$destination" /E
}

Get-ChildItem $pathSpec | ForEach-Object { 
	if ($_.FullName -ne "git-migrate.ps1"){
	
		$newPath = $_.FullName.Replace($path, $targetPath);  
	
		CopyFiles($_, $newPath);
		CreateNuSpec($newPath);
		InstallNuGetCli($newPath);
		#CreateGitRepository($_.Name, $newPath);
		
		# Debug - exit after first directory
		exit 1;
	}
}
