$string = "\\dev1;\\dev2"
$string.Split(';') | ForEach-Object { 

echo "Deploying to $_"
echo ===========================
robocopy built-website "$_\Data01\Solutions\Classic Web Sites\%DeploymentDirectory%" /MIR /NDL /NC /NS /NP /V
}
