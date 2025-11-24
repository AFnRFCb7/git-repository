{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        visitor
                    } :
                        let
                            implementation =
                                {
                                    configs ? { } ,
                                    email ? null ,
                                    hooks ? { } ,
                                    name ? null ,
                                    post-setup ? null ,
                                    pre-setup ? null ,
                                    remotes ? { } ,
                                    ssh ? null ,
                                    submodules ? { }
                                } @set :
                                    {
                                        init =
                                            { mount , pkgs , resources , stage } @primary :
                                                let
                                                    application =
                                                        pkgs.writeShellApplication
                                                            {
                                                                name = "init" ;
                                                                runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                text =
                                                                    let
                                                                        mapper =
                                                                            let
                                                                                visitors =
                                                                                    {
                                                                                        configs =
                                                                                            {
                                                                                                bool = path : value : ''git config ${ builtins.elemAt path 0} ${ if value == true then "true" else "false" }'' ;
                                                                                                int = path : value : ''git config ${ builtins.elemAt path 0 } ${ builtins.toString value }'' ;
                                                                                                float = path : value : ''git config ${ builtins.elemAt path 0 } ${ builtins.toString value }'' ;
                                                                                                lambda = path : value : ''git config ${ builtins.elemAt path 0 } "${ value primary }"'' ;
                                                                                                null = path : value : ''#'' ;
                                                                                                path = path : value : ''git config ${ builtins.elemAt path 0 } ${ builtins.toString value }'' ;
                                                                                                string = path : value : ''git config ${ builtins.elemAt path 0 } "${ value }"'' ;
                                                                                            } ;
                                                                                        hooks =
                                                                                            {
                                                                                                lambda = path : value : ''ln --symbolic "${ value primary }" .git/hooks/${ builtins.elemAt path 0 }'' ;
                                                                                                path = path : value : ''ln --symbolic ${ builtins.toString value } .git/hooks/${ builtins.elemAt path 0 }'' ;
                                                                                                string = path : value : ''ln --symbolic "${ value }" .git/hooks/${ builtins.elemAt path 0 }'' ;
                                                                                            } ;
                                                                                        remotes =
                                                                                            {
                                                                                                lambda = path : value : ''git remote add ${ builtins.elemAt path 0 } "${ value primary }"'' ;
                                                                                                path = path : value : ''git remote add ${ builtins.elemAt path 0 } ${ builtins.toString value }'' ;
                                                                                                string = path : value : ''git remote add ${ builtins.elemAt path 0 } "${ value }"'' ;
                                                                                            } ;
                                                                                        setup =
                                                                                            let
                                                                                                string =
                                                                                                    string :
                                                                                                        ''
                                                                                                            if "$HAS_STANDARD_INPUT"
                                                                                                            then
                                                                                                                ${ string } "$@"
                                                                                                            else
                                                                                                                echo "$STANDARD_INPUT" | ${ string } "$@"
                                                                                                            fi
                                                                                                        '' ;
                                                                                                in
                                                                                                    {
                                                                                                        lambda = path : value : string ( value primary ) ;
                                                                                                        null = path : value : "#" ;
                                                                                                        string = path : value : string value ;
                                                                                                    } ;
                                                                                    } ;
                                                                                in
                                                                                    module-name :
                                                                                        {
                                                                                            configs ? { } ,
                                                                                            email ? email ,
                                                                                            hooks ? { } ,
                                                                                            name ? name ,
                                                                                            pre-setup ? null ,
                                                                                            post-setup ? null ,
                                                                                            remotes ? { } ,
                                                                                            ssh ? ssh ,
                                                                                            submodules ? { }
                                                                                        } :
                                                                                            let
                                                                                                sub = builtins.listToAttrs ( builtins.attrValues ( builtins.map ( { name , value } : { name = builtins.concatStringsSep "/" [ name module-name ] ; value = value ; } ) ( builtins.attrValues submodules ) ) ) ;
                                                                                                in
                                                                                                    ''
                                                                                                        cd ${ builtins.concatStringsSep "/" [ mount "repository" module-name ] }
                                                                                                        ${ visitor visitors.ssh ssh }
                                                                                                        ${ builtins.concatStringsSep "\n" ( visitor visitors.configs { "core.sshCommand" = ssh ; "user.email" = email ; "user.name " = name ; } ) } ;
                                                                                                        ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( visitor visitors.configs configs ) ) }
                                                                                                        ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( visitor visitors.hooks hooks ) ) }
                                                                                                        ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( visitor visitors.remotes remotes ) ) }
                                                                                                        ${ visitor visitors.setup pre-setup }
                                                                                                        git submodule init 2>&1
                                                                                                        git submodule update --init --update 2>&1
                                                                                                        ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs mapper sub ) ) }
                                                                                                        ${ visitor visitors.setup post-setup }
                                                                                                    '' ;
                                                                        ssh-command =
                                                                            {
                                                                                lambda =
                                                                                    path : value :
                                                                                        ''
                                                                                           GIT_SSH_COMMAND=${ value primary }
                                                                                           export GIT_SSH_COMMMAND
                                                                                        '' ;
                                                                                null = path : value : "#" ;
                                                                                string =
                                                                                    path : value :
                                                                                        ''
                                                                                            GIT_SSH_COMMAND=${ value }
                                                                                            export GIT_SSH_COMMAND
                                                                                        '' ;
                                                                            } ;
                                                                        in
                                                                            ''
                                                                                mkdir --parents /mount/repository
                                                                                cd /mount/repository
                                                                                git init 2>&1
                                                                                ${ visitor ssh-command ssh }
                                                                                mkdir --parents /mount/stage
                                                                                if [[ -t 0 ]]
                                                                                then
                                                                                    HAS_STANDARD_INPUT=true
                                                                                    STANDARD_INPUT="$( cat )" || failure 1098ed4e
                                                                                else
                                                                                    HAS_STANDARD_INPUT=false
                                                                                    STANDARD_INPUT=
                                                                                fi
                                                                                ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs mapper set ) ) }
                                                                            '' ;
                                                            } ;
                                                    in "${ application }/bin/init" ;
                                        targets = [ "repository" "stage" ] ;
                                    } ;
                            in
                                {
                                    check =
                                        {
                                            configs ? { } ,
                                            email ,
                                            expected ,
                                            failure ,
                                            hooks ? { } ,
                                            mount ? null ,
                                            name ,
                                            pkgs ,
                                            post-setup ? null ,
                                            pre-setup ? null ,
                                            remotes ? { } ,
                                            resources ? null ,
                                            stage ? null
                                        } :
                                            pkgs.stdenv.mkDerivation
                                                {
                                                    installPhase = ''execute-test "$out"'' ;
                                                    name = "check" ;
                                                    nativeBuildInputs =
                                                        [
                                                            (
                                                                pkgs.writeShellApplication
                                                                    {
                                                                        name = "execute-test" ;
                                                                        runtimeInputs = [ pkgs.coreutils failure ] ;
                                                                        text =
                                                                            let
                                                                                init = instance.init { mount = mount ; pkgs = pkgs ; resources = resources ; stage = stage ; } ;
                                                                                instance = implementation { configs = configs ; email = email ; hooks = hooks ; name = name ; post-setup = post-setup ; pre-setup = pre-setup ; remotes = remotes ; } ;
                                                                                in
                                                                                    ''
                                                                                        OUT="$1"
                                                                                        touch "$OUT"
                                                                                        ${ if [ "init" "targets" ] != builtins.attrNames instance then ''failure fd429b57 git-repository "We expected the names to be init targets but we observed ${ builtins.toJSON builtins.attrNames instance }"'' else "#" }
                                                                                        ${ if [ "repository" "stage" ] != instance.targets then ''failure 5c205b3b git-repository "We expected the targets to be repository stage but we observed "${ builtins.toJSON instance.targets }"'' else "#" }
                                                                                        ${ if init != expected then ''failure ecfb2043 git-repository "We expected the init to be ${ builtins.toString expected } but we observed ${ builtins.toString init }"'' else "" }
                                                                                    '' ;
                                                                    }
                                                            )
                                                        ] ;
                                                    src = ./. ;
                                                } ;
                                    implementation = implementation ;
                                } ;
            } ;
}
