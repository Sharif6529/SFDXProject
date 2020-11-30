@echo off

SET scratchname=%1
IF "%scratchname%"=="" (
    SET scratchname=newScratch
)

for /f "tokens=* USEBACKQ" %%i in (`powershell -Command "& {(sfdx force:org:create -s -f config\project-scratch-def.json -a %scratchname% -d 14 --json | ConvertFrom-Json).result.orgId}"`) do set orgId=%%i
echo orgId=%orgId%

call sfdx force:apex:execute -f scripts\setDefaultUserDetails.apex

::Five9CTIAdapter
call sfdx force:package:install --package 04tA0000000WbcsIAC --noprompt --wait 10
::Marketing Cloud
call sfdx force:package:install --package 04t0H000000gmOVQAY --noprompt --wait 10
::LiveMessage for Salesforce
call sfdx force:package:install --package 04t1J000000GeQrQAK --noprompt --wait 10
::CIC for Salesforce
call sfdx force:package:install --package 04t1a000000VUjSAAW --noprompt --wait 10

mkdir temp
move force-app\main\default\objects\Case\listViews\Open_Support_Cases.listView-meta.xml temp\Open_Support_Cases.listView-meta.xml
move force-app\main\default\objects\Case\listViews\Support_Case.listView-meta.xml temp\Support_Case.listView-meta.xml
move force-app\main\default\objects\Case\listViews\Support_Cases.listView-meta.xml temp\Support_Cases.listView-meta.xml
move force-app\main\default\objects\Case\recordTypes\Support_Case.recordType-meta.xml temp\Support_Case.recordType-meta.xml
move force-app\main\default\profiles\Admin.profile-meta.xml temp\Admin.profile.recordType-meta.xml
move "force-app\main\default\profiles\Campaign Manager.profile-meta.xml" "temp\Campaign Manager.profile.recordType-meta.xml"
move "force-app\main\default\profiles\Freedom User.profile-meta.xml" "temp\Freedom User.profile.recordType-meta.xml"
move "force-app\main\default\profiles\Loan Advisor.profile-meta.xml" "temp\Loan Advisor.profile.recordType-meta.xml"

call sfdx force:source:push -f

move temp\Open_Support_Cases.listView-meta.xml force-app\main\default\objects\Case\listViews\Open_Support_Cases.listView-meta.xml
move temp\Support_Case.listView-meta.xml  force-app\main\default\objects\Case\listViews\Support_Case.listView-meta.xml
move temp\Support_Cases.listView-meta.xml  force-app\main\default\objects\Case\listViews\Support_Cases.listView-meta.xml
move temp\Support_Case.recordType-meta.xml force-app\main\default\objects\Case\recordTypes\Support_Case.recordType-meta.xml
move temp\Admin.profile.recordType-meta.xml force-app\main\default\profiles\Admin.profile-meta.xml
move "temp\Campaign Manager.profile.recordType-meta.xml" "force-app\main\default\profiles\Campaign Manager.profile-meta.xml"
move "temp\Freedom User.profile.recordType-meta.xml" "force-app\main\default\profiles\Freedom User.profile-meta.xml"
move "temp\Loan Advisor.profile.recordType-meta.xml" "force-app\main\default\profiles\Loan Advisor.profile-meta.xml"
rmdir temp

call sfdx force:source:push -f

:: figure out getting org id into here
call sfdx force:user:create username=freedommortgageschedulingteam@freedommortgage.com.%orgId% profileName="Freedom User"
call sfdx force:user:create username=system.user@freedommortgage.com.%orgId% profileName="Loan Advisor"
call sfdx force:user:create username=mulesoftapi@freedommortgage.com.%orgId%

call sfdx force:data:tree:import --plan data\initial-data-plan.json
