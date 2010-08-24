%    __                        __      _
%   / /__________ __   _____  / /___  (_)___  ____ _
%  / __/ ___/ __ `/ | / / _ \/ / __ \/ / __ \/ __ `/
% / /_/ /  / /_/ /| |/ /  __/ / /_/ / / / / / /_/ /
% \__/_/   \__,_/ |___/\___/_/ .___/_/_/ /_/\__, /
%                           /_/            /____/
%
% Copyright (c) Travelping GmbH <info@travelping.com>

-module(tep_config).
-export([repositories/0, repository/1]).

-include("tetrapak.hrl").

config_path(File) ->
  HomeDir = os:getenv("HOME"),
  filename:join([HomeDir, ".tetrapak", File]).

%% ------------------------------------------------------------ 
%% -- Repository specs

repositories() ->
  File = config_path("repositories"),
  case file:consult(File) of
    {ok, Terms} -> 
      [repo_def_to_record(T) || T <- Terms];
    {error, enoent} -> [];
    {error, Error} -> 
      tep_log:warn("could not read repository config file ~s: ~s", 
        [File, file:format_error(Error)]),
      []
  end.

repo_def_to_record({repository, Name, Props}) ->
  case proplists:get_value(type, Props) of
    undefined -> 
      tep_log:warn("repository ~s has no type defined", [Name]),
      throw({error, repo_def_invalid});
    Type ->
      #tep_repository{name = Name, type = Type, options = Props}
  end.

repository(Name) ->
  Repos = repositories(),
  case lists:keyfind(Name, 2, Repos) of
    false -> {error, not_found};
    Repo ->  {ok, Repo}
  end.