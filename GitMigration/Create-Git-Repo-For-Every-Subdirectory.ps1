# Get-ChildItem -Recurse | ?{ $_.PSIsContainer } | ForEach-Object {   

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

}

Get-ChildItem $pathSpec | ForEach-Object { 
	if ($_.FullName -ne "git-migrate.ps1"){
	
		$newPath = $_.FullName.Replace($path, $targetPath);  
	
		CopyFiles($_, $newPath);
		CreateNuSpec($newPath);
		CreateGitRepository($_.Name, $newPath);
		
	}
}
