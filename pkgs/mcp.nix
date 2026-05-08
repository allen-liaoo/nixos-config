{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  hatchling,

  uv-dynamic-versioning,
  anyio,
  httpx-sse,
  httpx,
  pydantic-settings,
  pydantic,
  python-multipart,
  sse-starlette,
  starlette,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "mcp";
  version = "1.8.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Jj37cAVAtybAk/DD4EP2at7Qcw0LUfBOsKPrkAVf5Js=";
  };

  build-system = [
    setuptools
    hatchling
  ];

  dependencies = [
    uv-dynamic-versioning
    anyio
    httpx-sse
    httpx
    pydantic-settings
    pydantic
    python-multipart
    sse-starlette
    starlette
    uvicorn
  ];
}
