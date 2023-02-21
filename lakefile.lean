import Lake
open Lake DSL

package OpenSSL {
  precompileModules := true
  moreLinkArgs := #["-L", "./build/lib", "-lssl"]
}

@[defaultTarget]
lean_lib OpenSSL

def cDir   := "native"
def ffiSrc := "native.c"
def ffiO   := "ffi.o"
def ffiLib := "ffi"

target ffi.o (pkg : Package) : FilePath := do
  let oFile := pkg.buildDir / ffiO
  let srcJob ← inputFile <| pkg.dir / cDir / ffiSrc
  buildFileAfterDep oFile srcJob fun srcFile => do
    let flags := #["-I", (← getLeanIncludeDir).toString,
      "-I", (<- IO.getEnv "C_INCLUDE_PATH").getD "", "-fPIC"]
    compileO ffiSrc oFile srcFile flags

target ffi (pkg : Package) : FilePath := do
  let name := nameToStaticLib ffiLib
  let ffiO ← fetch <| pkg.target ``ffi.o
  buildStaticLib (pkg.buildDir / "lib" / name) #[ffiO]
