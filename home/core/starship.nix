{ lib, ... }:
{
  programs.starship = {
    enable = lib.mkForce true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };
}
