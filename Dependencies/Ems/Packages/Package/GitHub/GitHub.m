(* ::Package:: *)

(* Autogenerated Package *)

CreateSiteRepo::usage=
  "Creates a repository for a website";
PublishSiteRepo::usage=
  "Publishes a repository for a website";


Begin["`Private`"];


Ems; (* invoke the autoloader *)


(* ::Subsubsection::Closed:: *)
(*CreateSiteRepo*)



(* ::Subsubsubsection::Closed:: *)
(*getSiteName*)



getSiteName[siteDir_String?DirectoryQ]:=
  Lookup[
    SiteOptions[siteDir, "SiteName"],
    "SiteName",
    FileBaseName@siteDir
    ]


(* ::Subsubsubsection::Closed:: *)
(*getSiteRepo*)



getSiteRepo[siteDir_, repoName:_String|Automatic:Automatic]:=
  With[{u=Git["GetRemoteURL", siteDir]},
    If[URLParse[u, "Domain"]=!="github.com",
      URL@GitHub["Path", Replace[repoName, Automatic:>getSiteName[siteDir]]],
      u
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*setSiteRemote*)



setSiteRemote[siteDir_, repoName:_String|Automatic:Automatic]:=
  With[{repo=getSiteRepo[siteDir, repoName]},
    Check[
      Git["AddRemote", siteDir, repo],
      Git["RemoveRemote", siteDir, repo];
      Git["AddRemote", siteDir, repo]
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*siteRealignRemotes*)



realignRemotes[siteDir_]:=
  (
    Git["Fetch", siteDir];
    Git["Reset", siteDir, "origin/master"];
    Git["Checkout", siteDir, "origin/master"];
    );


(* ::Subsubsubsection::Closed:: *)
(*siteGitInit*)



siteGitInit[siteDir_]:=
  Git["Init", siteDir]


(* ::Subsubsubsection::Closed:: *)
(*CreateSiteRepo*)



CreateSiteRepo[
  siteDir_String?DirectoryQ,
  repoName:_String|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  Module[{repo,repoExistsQ},
    repo=getSiteRepo[siteDir];
    If[!Git["RepoQ", siteDir],
      siteGitInit[siteDir];
      setSiteRemote[siteDir];
      repoExistsQ=Between[URLRead[repo,"StatusCode"], {200,299}];
      If[repoExistsQ, realignRemotes[siteDir]]
      ];
    If[Git["RepoQ", siteDir],
      If[!ValueQ[repoExistsQ],
        repoExistsQ=Between[URLRead[repo, "StatusCode"],{200,299}]
        ];
      If[!repoExistsQ,
        GitHub["Create", 
          Replace[repoName, Automatic:>getSiteName[siteDir]], 
          "ImportedResult"
          ];
        setSiteRemote[siteDir]
        ];
      repo
      ]
    ];
CreateSiteRepo[
  name_String,
  ops:OptionsPattern[]
  ]:=
  With[{d=FileNameJoin@{$SiteDirectory, name}},
    CreateSiteRepo[d, ops]/;DirectoryQ@d
    ]


(* ::Subsubsection::Closed:: *)
(*PublishSiteRepo*)



PublishSiteRepo[
  siteDir_String?DirectoryQ,
  ops:OptionsPattern[]
  ]:=
  If[Git["RepoQ", siteDir]&&Length@Git["ListRemotes", siteDir]>0,
    Git["Commit", siteDir]....???;
    Git["PullOrigin", siteDir];
    GitHub["Push", siteDir, "IncludePassword"->True],
    PackageRaiseException[
      Automatic,
      "Website `` isn't a valid git repo with a set remote",
      siteDir
      ]
    ];
PublishSiteRepo[
  name_String,
  ops:OptionsPattern[]
  ]:=
  With[{d=FileNameJoin@{$SiteDirectory, name}},
    PublishSiteRepo[d, ops]/;DirectoryQ@d
    ]


End[];


