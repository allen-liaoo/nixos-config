# represents the content of users_database.yml
{
  users = {
    allenliao = {
      disabled = false;
      displayname = "Allen Liao";
      email = "wcliaw610@gmail.com";
      groups = [
        "admin"
        "authelia_users"
      ];
    };

    allenliao_radicale = {
      disabled = false;
      displayname = "Allen Liao Radicale";
      email = "allenliao_radicale@dummy";
      groups = [ "radicale_users" ];
    };

    authelia = {
      disabled = false;
      displayname = "Authelia";
      email = "authelia@dummy";
      groups = [ "service" ];
    };

    radicale = {
      disabled = false;
      displayname = "Radicale";
      email = "radicale@dummy";
      groups = [ "service" ];
    };
  };
}