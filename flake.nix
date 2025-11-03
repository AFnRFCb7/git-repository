{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        coreutils ,
                        git ,
                        writeShellApplication
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
                                            { pkgs , resources , self } :
                                                let
                                                    application =
                                                        writeShellApplication
                                                            {
                                                                name = "init" ;
                                                                runtimeInputs = [ coreutils git ] ;
                                                                text =
                                                                    ''
                                                                        mkdir --parents /mount/git-repository
                                                                        cd /mount/git-repository
                                                                        git init 2>&1
                                                                        ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''git config "${ name }" "${ value }"'' ) configs ) ) }
                                                                        ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''ln --symbolic "${ value }" ".git/hooks/${ name }"'' ) hooks ) ) }
                                                                        ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''git remote add "${ name }" "${ value }"'' ) remotes ) ) }
                                                                        ${ if builtins.typeOf setup == "null" then "#" else setup }
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
                                            mkDerivation ,
                                            pkgs ? null ,
                                            remotes ? { } ,
                                            resources ? null ,
                                            self ? null ,
                                            setup ? null
                                        } :
                                            mkDerivation
                                                {
                                                    installPhase = ''execute-test "$out"'' ;
                                                    name = "check" ;
                                                    nativeBuildInputs =
                                                        [
                                                            (
                                                                writeShellApplication
                                                                    {
                                                                        name = "execute-test" ;
                                                                        runtimeInputs = [ coreutils ( failure "b951ae86" ) ] ;
                                                                        text =
                                                                            let
                                                                                init = instance.init { resources = resources ; self = self ; } ;
                                                                                instance = implementation { pkgs = pkgs ; configs = configs ; hooks = hooks ; remotes = remotes ; setup = setup ; } ;
                                                                                in
                                                                                    ''
                                                                                        OUT="$1"
                                                                                        touch "$OUT"
                                                                                        ${ if [ "init" "targets" ] != builtins.attrNames instance then ''failure name "${ builtins.toJSON builtins.attrNames instance }"'' else "#" }
                                                                                        ${ if [ "git-repository" ] != instance.targets then ''failure targets "${ builtins.toJSON instance.targets }"'' else "#" }
                                                                                        ${ if init != expected then ''failure init "${ init }"'' else "" }
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