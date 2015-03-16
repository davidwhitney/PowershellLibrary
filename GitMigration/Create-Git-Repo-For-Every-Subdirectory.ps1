# Get-ChildItem -Recurse | ?{ $_.PSIsContainer } | ForEach-Object {   

Get-ChildItem "C:\dev\svn\Solutions\Windows Applications\*" | ForEach-Object { 
	if ($_.FullName -ne "git-migrate.ps1"){
	
		$newPath = $_.FullName.Replace("\svn\Solutions","\git-svn");
		New-Item $newPath -ItemType Directory -ErrorAction SilentlyContinue;   
	
		$gitRepoName = $_.Name.Replace(" ", "-");
	
		robocopy $_ $newPath /E
		cd $newPath
		git init
		git add .
		git commit -m "Import"
		git remote add origin ssh://git@stash.euromoneydigital.com:7999/winapps/$gitRepoName.git
	}
	
}