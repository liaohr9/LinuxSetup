
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'ya' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'ya'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-') -or
                $element.Value -eq $wordToComplete) {
                break
        }
        $element.Value
    }) -join ';'

    $completions = @(switch ($command) {
        'ya' {
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('emit', 'emit', [CompletionResultType]::ParameterValue, 'Emit a command to be executed by the current instance')
            [CompletionResult]::new('emit-to', 'emit-to', [CompletionResultType]::ParameterValue, 'Emit a command to be executed by the specified instance')
            [CompletionResult]::new('pkg', 'pkg', [CompletionResultType]::ParameterValue, 'Manage packages')
            [CompletionResult]::new('pack', 'pack', [CompletionResultType]::ParameterValue, 'Manage packages')
            [CompletionResult]::new('pub', 'pub', [CompletionResultType]::ParameterValue, 'Publish a message to the current instance')
            [CompletionResult]::new('pub-to', 'pub-to', [CompletionResultType]::ParameterValue, 'Publish a message to the specified instance')
            [CompletionResult]::new('sub', 'sub', [CompletionResultType]::ParameterValue, 'Subscribe to messages from all remote instances')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'ya;emit' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;emit-to' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;pkg' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add packages')
            [CompletionResult]::new('delete', 'delete', [CompletionResultType]::ParameterValue, 'Delete packages')
            [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Install all packages')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all packages')
            [CompletionResult]::new('upgrade', 'upgrade', [CompletionResultType]::ParameterValue, 'Upgrade all packages')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'ya;pkg;add' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;pkg;delete' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;pkg;install' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;pkg;list' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;pkg;upgrade' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;pkg;help' {
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add packages')
            [CompletionResult]::new('delete', 'delete', [CompletionResultType]::ParameterValue, 'Delete packages')
            [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Install all packages')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all packages')
            [CompletionResult]::new('upgrade', 'upgrade', [CompletionResultType]::ParameterValue, 'Upgrade all packages')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'ya;pkg;help;add' {
            break
        }
        'ya;pkg;help;delete' {
            break
        }
        'ya;pkg;help;install' {
            break
        }
        'ya;pkg;help;list' {
            break
        }
        'ya;pkg;help;upgrade' {
            break
        }
        'ya;pkg;help;help' {
            break
        }
        'ya;pack' {
            [CompletionResult]::new('-a', '-a', [CompletionResultType]::ParameterName, 'Add packages')
            [CompletionResult]::new('--add', '--add', [CompletionResultType]::ParameterName, 'Add packages')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Delete packages')
            [CompletionResult]::new('--delete', '--delete', [CompletionResultType]::ParameterName, 'Delete packages')
            [CompletionResult]::new('-i', '-i', [CompletionResultType]::ParameterName, 'Install all packages')
            [CompletionResult]::new('--install', '--install', [CompletionResultType]::ParameterName, 'Install all packages')
            [CompletionResult]::new('-l', '-l', [CompletionResultType]::ParameterName, 'List all packages')
            [CompletionResult]::new('--list', '--list', [CompletionResultType]::ParameterName, 'List all packages')
            [CompletionResult]::new('-u', '-u', [CompletionResultType]::ParameterName, 'Upgrade all packages')
            [CompletionResult]::new('--upgrade', '--upgrade', [CompletionResultType]::ParameterName, 'Upgrade all packages')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;pub' {
            [CompletionResult]::new('--str', '--str', [CompletionResultType]::ParameterName, 'Send the message with a string body')
            [CompletionResult]::new('--json', '--json', [CompletionResultType]::ParameterName, 'Send the message with a JSON body')
            [CompletionResult]::new('--list', '--list', [CompletionResultType]::ParameterName, 'Send the message as a list of strings')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;pub-to' {
            [CompletionResult]::new('--str', '--str', [CompletionResultType]::ParameterName, 'Send the message with a string body')
            [CompletionResult]::new('--json', '--json', [CompletionResultType]::ParameterName, 'Send the message with a JSON body')
            [CompletionResult]::new('--list', '--list', [CompletionResultType]::ParameterName, 'Send the message as a list of strings')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;sub' {
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'ya;help' {
            [CompletionResult]::new('emit', 'emit', [CompletionResultType]::ParameterValue, 'Emit a command to be executed by the current instance')
            [CompletionResult]::new('emit-to', 'emit-to', [CompletionResultType]::ParameterValue, 'Emit a command to be executed by the specified instance')
            [CompletionResult]::new('pkg', 'pkg', [CompletionResultType]::ParameterValue, 'Manage packages')
            [CompletionResult]::new('pack', 'pack', [CompletionResultType]::ParameterValue, 'Manage packages')
            [CompletionResult]::new('pub', 'pub', [CompletionResultType]::ParameterValue, 'Publish a message to the current instance')
            [CompletionResult]::new('pub-to', 'pub-to', [CompletionResultType]::ParameterValue, 'Publish a message to the specified instance')
            [CompletionResult]::new('sub', 'sub', [CompletionResultType]::ParameterValue, 'Subscribe to messages from all remote instances')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'ya;help;emit' {
            break
        }
        'ya;help;emit-to' {
            break
        }
        'ya;help;pkg' {
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add packages')
            [CompletionResult]::new('delete', 'delete', [CompletionResultType]::ParameterValue, 'Delete packages')
            [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Install all packages')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all packages')
            [CompletionResult]::new('upgrade', 'upgrade', [CompletionResultType]::ParameterValue, 'Upgrade all packages')
            break
        }
        'ya;help;pkg;add' {
            break
        }
        'ya;help;pkg;delete' {
            break
        }
        'ya;help;pkg;install' {
            break
        }
        'ya;help;pkg;list' {
            break
        }
        'ya;help;pkg;upgrade' {
            break
        }
        'ya;help;pack' {
            break
        }
        'ya;help;pub' {
            break
        }
        'ya;help;pub-to' {
            break
        }
        'ya;help;sub' {
            break
        }
        'ya;help;help' {
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
