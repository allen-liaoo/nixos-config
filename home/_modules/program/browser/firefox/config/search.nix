{
  default = "ddg";
  force = true;
  order = [
    "ddg"
    "mynixos"
  ];
  engines = {
    "google".metaData.hidden = true;
    "amazondotcom-us".metaData.hidden = true;
    "bing".metaData.hidden = true;
    "ebay".metaData.hidden = true;
    "perplexity".metaData.hidden = true;
    "wikipedia".metaData.hidden = true;
  };
}
