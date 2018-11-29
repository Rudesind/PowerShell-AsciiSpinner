<# 
    Module : AsciiSpinner.psm1
    Updated: 11/29/2018
    Author : Rudesind <rudesind76@gmail.com>
    Version: 1.0

    Summary:
    This module creates an ASCII "spinner" using the 'Write-Progress" function 
    of PowerShell to create a simple processing animation for a background 
    running task.
#>

Function Start-Spinner {

    <#
    .Synopsis
        This function creates an animated spinner for a running task.
    .Description
        This module creates an ASCII "spinner" using the 'Write-Progress" function 
        of PowerShell to create a simple processing animation for a background 
        running task.
    .Notes
        Module : AsciiSpinner.psm1
        Updated: 11/29/2018
        Author : Rudesind <rudesind76@gmail.com>
        Version: 1.0
    .Inputs
        System.Management.Automation.ScriptBlock
        System.String
        System.Int32
    .Parameter Script
        The script block that includes the command(s) to run.
    .Parameter MessageText
        The message to display while the task is executing.
    .Parameter UserAni
        The ASCII animation to display. Select: 0-1. Default 0.
    .Example
        Start-Spinner {Start-Sleep 5} "Sleeping"
    .Example
        $scriptBlc = {Start-Sleep 5}
        $message = "Loading..."
        Start-Spinner $scriptBlc $message

    #>

    [CmdletBinding()]
    Param (

        # User script block to execute in background
        #
        [validateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        [ScriptBlock] $Script, 
    
        # Message to display while executing
        #
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        [string] $MessageText,
        
        # (Optional) Animation to display while waiting
        #
        [ValidateNotNullOrEmpty()]
        [int]  $UserAni = 0

    )

    # Initialize the function
    #
    try {

        # A hash table of string arrays of all the animations and their delays
        #
        [object] $animation = @(
            ,@("|", "/", "-", "\", 100)
            ,@(".", "..", "...", 1000))
                
        # Varaiable is used to track current animation frame
        #
        [int] $count = 0

        # Holds the job for the background task
        # Type not included. Unsure
        #
        $job = $null

    } catch {
        $errorMsg = "Function initialize failed: " + $Error[0] + $_.Exception.Message
        throw $errorMsg
    }

    try {

        # Start the user script as a background job
        #
        $job = Start-Job -ScriptBlock $Script

        # Run loop for animation while job is running
        #
        while($job.JobStateInfo.State -eq "Running") {

            # Display animation based on current frame
            #
            Write-Progress -Activity $MessageText -Status $animation[$UserAni][$count % ($animation[$UserAni].count - 1 )]

            # Wait until animating next from
            #
            Start-Sleep -Milliseconds $animation[$UserAni][$animation[$UserAni].count -1]

            # Increment to next frame
            #
            $count++

        }

        # Check for job failure
        #
        if ($job.JobStateInfo.State -eq "Failed") {

            # Job failed. Throw exception
            #
            throw $job.ChildJobs[0].JobStateInfo.Reason

        }

    } catch {
        $errorMsg = "Error, spinner process failed. Final status: " +  $job.JobStateInfo.State + " " + $job.ChildJobs[0].JobStateInfo.Reason + " " + $Error[0] + " " +  $_.Exception.Message
        throw $errorMsg
    }

}