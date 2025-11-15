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
                                    hooks ? { } ,
                                    remotes ? { } ,
                                    setup ? null
                                } :
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
                                                                        config-visit =
                                                                            visitor
                                                                                {
                                                                                    lambda = path : value : ''git config ${ builtins.elemAt path 0 } "${ value primary }"'' ;
                                                                                    string = path : value : ''git config ${ builtins.elemAt path 0 } "${ value }"'' ;
                                                                                }
                                                                                configs ;
                                                                        setup-visit =
                                                                            let
                                                                                string =
                                                                                    string :
                                                                                        ''
                                                                                            if [[ -t 0 ]]
                                                                                            then
                                                                                                ${ string } "$@"
                                                                                            else
                                                                                                cat | ${ string } "$@"
                                                                                            fi
                                                                                        '' ;
                                                                                in
                                                                                    visitor
                                                                                        {
                                                                                            lambda = path : value : string ( value primary ) ;
                                                                                            null = path : value : "#" ;
                                                                                            string = path : value : string value ;
                                                                                        }
                                                                                        setup ;
                                                                        in
                                                                            ''
                                                                                mkdir --parents /mount/git-repository
                                                                                echo 67146884-cc26-4917-a2a4-7aa136a2a697 >> /tmp/DEBUG2
                                                                                cd /mount/git-repository
                                                                                echo b8d0a6e1-1e72-4cbd-9905-b73065ead0f7 >> /tmp/DEBUG2
                                                                                git init 2>&1
                                                                                # echo 55810896-78f1-41a4-8082-c0f1fc2ce91d >> /mount/git-repository/DEBUG2
                                                                                ${ if builtins.typeOf self == "string" then ''cd ${ mount }/git-repository'' else "#" }
                                                                                # echo a3f5a2af-710e-4cb2-84a4-d63643d0756d >> /tmp/DEBUG2
                                                                                ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( config-visit ) ) }
                                                                                # echo 06feede4-231a-4a0f-9e88-2515ec7851c3 >> /tmp/DEBUG2
                                                                                ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''ln --symbolic "${ value }" ".git/hooks/${ name }"'' ) hooks ) ) }
                                                                                # echo dfdf21b5-cff1-4514-ad00-c2ec953db1af >> /tmp/DEBUG2
                                                                                ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''git remote add "${ name }" "${ value }"'' ) remotes ) ) }
                                                                                echo e7920f2a-8761-48f3-b20d-0c62ed74c05d >> /tmp/DEBUG2
                                                                                ${ setup-visit }
                                                                                echo ba79940a-a4be-4fd9-9f6e-776475f43e5d >> /tmp/DEBUG2
                                                                            '' ;
                                                            } ;
                                                    in "${ application }/bin/init" ;
                                        targets = [ "git-repository" ] ;
                                    } ;
                            in
                                {
                                    check =
                                        {
                                            configs ? { } ,
                                            expected ,
                                            failure ,
                                            hooks ? { } ,
                                            mount ? null ,
                                            pkgs ,
                                            remotes ? { } ,
                                            resources ? null ,
                                            stage ? null ,
                                            setup ? null
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
                                                                                instance = implementation { configs = configs ; hooks = hooks ; remotes = remotes ; setup = setup ; } ;
                                                                                in
                                                                                    ''
                                                                                        OUT="$1"
                                                                                        touch "$OUT"
                                                                                        ${ if [ "init" "targets" ] != builtins.attrNames instance then ''failure fd429b57 "We expected the git-repository names to be init targets but we observed ${ builtins.toJSON builtins.attrNames instance }"'' else "#" }
                                                                                        ${ if [ "git-repository" ] != instance.targets then ''failure 5c205b3b "We expected the git-repository targets to be git-repository but we observed "${ builtins.toJSON instance.targets }"'' else "#" }
                                                                                        ${ if init != expected then ''failure ecfb2043 "We expected the git-repository init to be ${ builtins.toString expected } but we observed ${ builtins.toString init }"'' else "" }
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