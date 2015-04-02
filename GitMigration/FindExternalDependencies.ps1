
$path = "C:\dev\svn\Solutions\Class Libraries";


function MapExternalDependencies($destination)
{
	echo "Scanning for dependencies in $destination"
    
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

            #Write-Host Depends on $match.Line
            $dep = ($match.Line -replace "^.+\\External Dependencies", "External Dependencies").Replace("</HintPath>", "").trim();
            Write-Host Dependency is $dep
            #$newSln = $match.Path + ".new"
		    #$content = gc $match.Path;
            #Write-Host $content
		    #$content = $content.replace(' ',' ');
		    #sc $newSln $content;
	
	        # (gc c:\temp\test.txt).replace('[MYID]','MyValue')|sc c:\temp\test.txt
		    # gc - get content
		    # sc - set content
        }

        #break;
	
	}
}

MapExternalDependencies($path);