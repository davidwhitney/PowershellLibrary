
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


            $dep = ($match.Line -replace "^.+\\External Dependencies", "").Replace("</HintPath>", "").trim
            $replacementHint = ($match.Line -replace "^.+\\External Dependencies", "<HintPath>..\lib");

            #Write-Host Dependency is $dep

            Write-Host Replace 
            Write-Host $match.Line.Trim() with
            Write-Host $replacementHint


		    $content = gc $match.Path;
            #Write-Host $content
		    $updatedContent = ($content -replace "^.+\\External Dependencies", "<HintPath>..\lib");

            $newSln = $match.Path + ".new"		    
            sc $newSln $updatedContent;
	
	        # (gc c:\temp\test.txt).replace('[MYID]','MyValue')|sc c:\temp\test.txt
		    # gc - get content
		    # sc - set content
        }

        #break;
	
	}
}

MapExternalDependencies($path);