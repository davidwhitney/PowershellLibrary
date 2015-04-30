
$path = "C:\dev\svn\Solutions\Class Libraries";


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
            echo f | xcopy /f /y $fullDep c:\fakeDep$dep

		    $content = gc $match.Path;
		    $updatedContent = ($content -replace "^.+\\External Dependencies", "<HintPath>..\lib");	    
            #sc $match.Path $updatedContent;
        }

        pause;

        #break;
	
	}
}

MapExternalDependencies($path);