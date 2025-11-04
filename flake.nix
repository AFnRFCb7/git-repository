{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
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
                                                        pkgs.writeShellApplication
                                                            {
                                                                name = "init" ;
                                                                runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                text =
                                                                    ''
                                                                        mkdir --parents /mount/git-repository
                                                                        cd /mount/git-repository
                                                                        git init 2>&1
                                                                        ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''git config "${ name }" "${ value }"'' ) configs ) ) }
                                                                        ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''ln --symbolic "${ value }" ".git/hooks/${ name }"'' ) hooks ) ) }
                                                                        ${ builtins.concatStringsSep "\n" ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''git remote add "${ name }" "${ value }"'' ) remotes ) ) }
                                                                        if [[ -t 0 ]]
                                                                        then
                                                                            ${ if builtins.typeOf setup == "null" then "#" else "${ setup } ${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" }
                                                                        else
                                                                            ${ if builtins.typeOf setup == "null" then "#" else "cat | ${ setup } ${ builtins.concatStringsSep "" [ "$" "{" "@" "}" ] }" }
                                                                        fi
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
                                            pkgs ? null ,
                                            remotes ? { } ,
                                            resources ? null ,
                                            self ? null ,
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
                                                                                init = instance.init { pkgs = pkgs ; resources = resources ; self = self ; } ;
                                                                                instance = implementation { configs = configs ; hooks = hooks ; remotes = remotes ; setup = setup ; } ;
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