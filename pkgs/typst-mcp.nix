{
  buildPythonApplication,
  fetchFromGitHub,
  lib,
  setuptools,

  typst,
  typst-docs,

  mcp,
  numpy,
  pillow,
}:

lib.warnIf (typst.version != typst-docs.version)
  "typst-mcp: typst (${typst.version}) and typst-docs-assets (${typst-docs.version}) version mismatch — docs may be out of sync"

  (
    buildPythonApplication rec {
      pname = "typst-mcp";
      version = "c9a1d897712540db5d7a4147f0d648504b4fc246";
      pyproject = true;

      src = fetchFromGitHub {
        owner = "johannesbrandenburger";
        repo = pname;
        rev = version;
        hash = "sha256-9hvPdQZfYlHyJS8ACLnPG1n5Yxf6+tv6L0RokVVMXKY=";
      };

      build-system = [ setuptools ];

      postPatch = ''
        # Add entrypoint in src
        cat >> server.py << 'EOF'

        def main():
            mcp.run()
        EOF

        # Add entrypoint in pyproject
        substituteInPlace pyproject.toml \
          --replace-fail \
            '[project]' \
            '[project.scripts]
            typst-mcp = "server:main"

            [project]'

        # Patch the hardcoded relative path of typst-docs before the build sees the source
        substituteInPlace server.py \
          --replace-fail \
            'os.path.join(os.path.dirname(__file__), "typst-docs", "main.json")' \
            'os.environ.get("TYPST_MCP_DOCS_JSON", os.path.join(os.path.dirname(__file__), "typst-docs", "main.json"))'
      '';

      postInstall = ''
        wrapProgram $out/bin/typst-mcp \
          --set TYPST_MCP_DOCS_JSON "${typst-docs}/main.json" \
      ''; # --prefix PATH : ${lib.makeBinPath [ typst ]}

      dependencies = [
        mcp
        numpy
        pillow
        typst
      ];

      pythonImportsCheck = [
        "mcp"
        "numpy"
        "PIL" # pillow
      ];

      meta = {
        description = "MCP server for Typst";
        longDescription = ''
          Typst MCP Server is an MCP (Model Context Protocol) implementation that helps AI models interact with Typst, a markup-based typesetting system. The server provides tools for converting between LaTeX and Typst, validating Typst syntax, and generating images from Typst code. 
        '';
        homepage = "https://github.com/johannesbrandenburger/typst-mcp";
        license = lib.licenses.mit;
        mainProgram = "typst-mcp";
      };
    }
  )
