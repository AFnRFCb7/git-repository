{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        string ,
                        visitor
                    } :
                        let
                            implementation =
                                {
                                    configs ? { } ,
                                    email ? null ,
                                    follow-parent ? false ,
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
                                            { mount , pkgs , resources } @primary :
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
                                                                                defaults =
                                                                                    {
                                                                                        follow-parent = follow-parent ;
                                                                                        email = email ;
                                                                                        name = name ;
                                                                                        ssh = ssh ;
                                                                                    } ;
                                                                                visitors =
                                                                                    let
                                                                                        stage = string { template = { mount } : "${ mount }/stage" ; values = { mount = mount ; } ; } ;
                                                                                        in
                                                                                            {
                                                                                                configs =
                                                                                                    {
                                                                                                        bool = path : value : ''git config ${ builtins.elemAt path 0} ${ if value == true then "true" else "false" }'' ;
                                                                                                        int = path : value : ''git config ${ builtins.elemAt path 0 } ${ builtins.toString value }'' ;
                                                                                                        float = path : value : ''git config ${ builtins.elemAt path 0 } ${ builtins.toString value }'' ;
                                                                                                        lambda = path : value : ''git config ${ builtins.elemAt path 0 } "${ value stage }"'' ;
                                                                                                        null = path : value : ''#'' ;
                                                                                                        path = path : value : ''git config ${ builtins.elemAt path 0 } ${ builtins.toString value }'' ;
                                                                                                        string = path : value : ''git config ${ builtins.elemAt path 0 } "${ value }"'' ;
                                                                                                    } ;
                                                                                                hooks =
                                                                                                    {
                                                                                                        lambda = path : value : ''ln --symbolic "${ value stage }" .git/hooks/${ builtins.elemAt path 0 }'' ;
                                                                                                        path = path : value : ''ln --symbolic ${ builtins.toString value } .git/hooks/${ builtins.elemAt path 0 }'' ;
                                                                                                        string = path : value : ''ln --symbolic "${ value }" .git/hooks/${ builtins.elemAt path 0 }'' ;
                                                                                                    } ;
                                                                                                remotes =
                                                                                                    {
                                                                                                        lambda = path : value : ''git remote add ${ builtins.elemAt path 0 } "${ value stage }"'' ;
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
                                                                                            email ? defaults.email ,
                                                                                            follow-parent ? defaults.follow-parent ,
                                                                                            hooks ? { } ,
                                                                                            name ? defaults.name ,
                                                                                            pre-setup ? null ,
                                                                                            post-setup ? null ,
                                                                                            remotes ? { } ,
                                                                                            ssh ? defaults.ssh ,
                                                                                            submodules ? { }
                                                                                        } :
                                                                                            let
                                                                                                sub = builtins.listToAttrs ( builtins.attrValues ( builtins.mapAttrs ( name : value : { name = builtins.concatStringsSep "/" [ module-name name ] ; value = value ; } ) submodules ) ) ;
                                                                                                in
                                                                                                    string
                                                                                                        {
                                                                                                            template =
                                                                                                                { configs , defaults , hooks , module-name , post-setup , pre-setup , remotes , submodules } :
                                                                                                                    ''
                                                                                                                        cd "${ module-name }"
                                                                                                                        ${ defaults }
                                                                                                                        ${ configs }
                                                                                                                        ${ hooks }
                                                                                                                        ${ remotes }
                                                                                                                        ${ pre-setup }
                                                                                                                        git submodule init 2>&1
                                                                                                                        git submodule update --init --checkout 2>&1
                                                                                                                        ${ submodules }
                                                                                                                        ${ post-setup }
                                                                                                                    '' ;
                                                                                                            values =
                                                                                                                {
                                                                                                                    configs = builtins.concatStringsSep "\n" ( builtins.attrValues ( visitor visitors.configs configs ) ) ;
                                                                                                                    hooks = builtins.concatStringsSep "\n" ( builtins.attrValues ( visitor visitors.hooks hooks ) ) ;
                                                                                                                    defaults = builtins.concatStringsSep "\n" ( builtins.attrValues ( visitor visitors.configs { "core.sshCommand" = ssh ; "user.email" = email ; "user.name" = name ; } ) ) ;
                                                                                                                    module-name = module-name ;
                                                                                                                    post-setup = visitor visitors.setup post-setup ;
                                                                                                                    pre-setup = visitor visitors.setup pre-setup ;
                                                                                                                    remotes = builtins.concatStringsSep "\n" ( builtins.attrValues ( visitor visitors.remotes remotes ) ) ;
                                                                                                                    submodules = builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs mapper sub ) ) ;
                                                                                                                } ;
                                                                                                        } ;
                                                                        root-name = string { template = { mount } : "${ mount }/repository" ; values = { mount = mount ; } ; } ;
                                                                        ssh-command =
                                                                            {
                                                                                lambda =
                                                                                    path : value :
                                                                                        string
                                                                                            {
                                                                                                template =
                                                                                                    { mount } :
                                                                                                        ''
                                                                                                           # shellcheck disable=SC2034
                                                                                                           GIT_SSH_COMMAND="${ value "${ mount }/stage" }"
                                                                                                           export GIT_SSH_COMMMAND
                                                                                                        '' ;
                                                                                                values = { mount = mount ; } ;
                                                                                            } ;
                                                                                null = path : value : "#" ;
                                                                                string =
                                                                                    path : value :
                                                                                        ''
                                                                                            # shellcheck disable=SC2034
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
                                                                                    # shellcheck disable=SC2034
                                                                                    HAS_STANDARD_INPUT=false
                                                                                    # shellcheck disable=SC2034
                                                                                    STANDARD_INPUT=
                                                                                else
                                                                                    # shellcheck disable=SC2034
                                                                                    HAS_STANDARD_INPUT=true
                                                                                    # shellcheck disable=SC2034
                                                                                    STANDARD_INPUT="$( cat )" || failure 1098ed4e
                                                                                fi
                                                                                ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs mapper { "${ root-name }" = set ; } ) ) }
                                                                            '' ;
                                                            } ;
                                                    in "${ application }/bin/init" ;
                                        follow-parent = follow-parent ;
                                        targets = [ "repository" "stage" ] ;
                                    } ;
                            in
                                {
                                    check =
                                        {
                                            configs ? { } ,
                                            email ? null ,
                                            expected ,
                                            failure ,
                                            follow-parent ? false ,
                                            hooks ? { } ,
                                            mount ? null ,
                                            name ? null ,
                                            pkgs ,
                                            post-setup ? null ,
                                            pre-setup ? null ,
                                            remotes ? { } ,
                                            resources ? null ,
                                            ssh ? null ,
                                            submodules ? { }
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
                                                                                init = instance.init { mount = mount ; pkgs = pkgs ; resources = resources ; } ;
                                                                                instance =
                                                                                    implementation
                                                                                        {
                                                                                            configs = configs ;
                                                                                            email = email ;
                                                                                            follow-parent = follow-parent ;
                                                                                            hooks = hooks ;
                                                                                            name = name ;
                                                                                            post-setup = post-setup ;
                                                                                            pre-setup = pre-setup ;
                                                                                            remotes = remotes ;
                                                                                            ssh = ssh ;
                                                                                            submodules = submodules ;
                                                                                        } ;
                                                                                in
                                                                                    ''
                                                                                        OUT="$1"
                                                                                        touch "$OUT"
                                                                                        ${ if [ "follow-parent" "init" "targets" ] != builtins.attrNames instance then ''failure fd429b57 git-repository "We expected the names to be init targets but we observed ${ builtins.toJSON ( builtins.attrNames instance ) }"'' else "#" }
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
