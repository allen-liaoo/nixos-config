{
  lib,
  alnLib,
  ctx,
  ...
}:

{
  imports = lib.optionals (ctx.host.is.gui) (alnLib.listDirFiles ./. ++ alnLib.listSubdirs ./.);
}
