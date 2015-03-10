using build
class Build : build::BuildPod
{
  new make()
  {
    podName = "FantomClient"
    summary = ""
    srcDirs = [`fan/`]
    depends = [
      "sys 1.0",
      "inet 0+",
      "concurrent 0+"
      ]
  }
}
