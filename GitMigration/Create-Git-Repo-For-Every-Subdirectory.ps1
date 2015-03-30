# Get-ChildItem -Recurse | ?{ $_.PSIsContainer } | ForEach-Object {   

$invocation = (Get-Variable MyInvocation).Value
$scriptHome = Split-Path $invocation.MyCommand.Path

$path = "C:\dev\svn\Solutions\Class Libraries";
$pathSpec = $path + "\*";
$targetPath = "c:\dev\git-svn\Class Libraries";

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

		xcopy "$scriptHome\template.nuspec" "$pathToProj" /Y /F
		Rename-Item "$pathToProj\template.nuspec" "$nameStem.nuspec"
	
		echo "Created $pathToProj"
	}
}

Get-ChildItem $pathSpec | ForEach-Object { 
	if ($_.FullName -ne "git-migrate.ps1"){
	
		$newPath = $_.FullName.Replace($path, $targetPath);  
	
		CopyFiles($_, $newPath);
		CreateNuSpec($newPath);
		CreateGitRepository($_.Name, $newPath);
		
		# Debug - exit after first directory
		exit 1;
	}
}
