(* ::Package:: *)

(* Autogenerated Package *)

(* ::Text:: *)
(*A bunch of lower level junk used in the top-level interface*)



LocalPacletServerPattern::usage=
  "The patterns that a local server can take";
(*CloudPacletServerPattern::usage=
	"The patterns that a cloud server can take";*)


PacletServer::usage="";
LoadPacletServers::usage="";
$DefaultPacletServer::usage=
  "The key of the default paclet server";


PacletServerURL::usage=
  "";
PacletServerDeploymentURL::usage=
  "";
PacletServerBundleSite::usage=
  "Bundles the site dataset for the server";
PacletServerFile::usage=
  "Finds a file on a paclet server";
PacletServerDirectory::usage=
  "";
PacletServerDataset::usage=
  "";
PacletServerExposedPaclets::usage=
  "";
PacletServerInitialize::usage="";
PacletServerDelete::usage=
  "Deletes a paclet server";


ExportPacletMarkdownNotebook::usage="";
PacletMarkdownNotebook::usage="";
PacletMarkdownNotebookUpdate::usage="";


RegeneratePacletPages::usage="";


Begin["`Private`"];


(* ::Subsection:: *)
(*Setup*)



(* ::Subsubsection::Closed:: *)
(*patternHack*)



pacletUploadPat=((_String|_URL|_File|{_String,_String}|_Paclet)|
  (_String|_Paclet->_String|_URL|_File|{_String,_String}|_Paclet))|
  {((_String|_URL|_File|{_String,_String}|_Paclet)|
      (_String|_Paclet->_String|_URL|_File|{_String,_String}|_Paclet))..};


(* ::Subsubsection::Closed:: *)
(*File*)



$PacletServersFile=
  FileNameJoin@{
    $UserBaseDirectory, 
    "ApplicationData",
    "PacletServers",
    "PacletServers.m"
    };


(* ::Subsubsection::Closed:: *)
(*Load*)



$PacletServersDefault=
    <|
      "Default"->
        $PacletExecuteSettings["ServerDefaults"],
      "Shared"->
        <|
          "ServerBase"->
            Replace[
              (* This serves my local purposes only... *)
              FileNameJoin@
                {
                  $UserDocumentsDirectory, 
                  "GitHub", 
                  "MathematicaPacletServer"
                  },
              Except[_?DirectoryQ]:>
                "https://www.wolframcloud.com/objects/PacletServer"
              ],
          "ServerExtension"->
            Nothing,
          "ServerName"->
            Nothing,
          Permissions->
            "Public",
          CloudConnect->
            "PacletServer"
          |>
      |>;


LoadPacletServers[]:=
  If[!AssociationQ@$PacletServers,
    $PacletServers=
      Merge[
        {
          If[FileExistsQ@$PacletServersFile,
            Import[$PacletServersFile],
            <||>
            ],
          $PacletServersDefault
          },
        First
        ]
    ]


(* ::Subsubsection::Closed:: *)
(*Merge*)



ImportPacletServers[d_Association]:=
  Merge[
    {
      Select[$PacletServers],
      d,
      Select[$PacletServers,
        DirectoryQ@*Key["ServerBase"]
        ]
      },
    Merge[Last]
    ];
ImportPacletServers[f_String]/;FileExistsQ[f]&&!DirectoryQ[f]:=
  ImportPacletServers@Import[f];
ImportPacletServers[f_String]:=
  Replace[Quiet@CloudObject[f],
    {
      co_CloudObject:>ImportPacletServers@co,
      _:>ImportPacletServers@Import[f]
      }
    ];
ImportPacletServers[c_CloudObject]:=
  ImportPacletServers@CloudImport[c];
ImportPacletServers[_]:=
  $Failed


(* ::Subsubsection::Closed:: *)
(*Index*)



If[Length@OwnValues[$PacletServersIndexes]==0,
  $PacletServersIndexes:=
    $PacletServersIndexes=
      <|
        "b3m2a1"->CloudObject["user:b3m2a1.paclets/PacletIndex.m"]
        |>
  ];


(* ::Subsubsection::Closed:: *)
(*Setup*)



If[!AssociationQ@$PacletServers,
  LoadPacletServers[]
  ]


$DefaultPacletServer=
  "Default";


PacletServer[s_]:=
  Normal@$PacletServers[s]


$PacletServer:=
  PacletServer[$DefaultPacletServer]


LocalPacletServerPattern=
  KeyValuePattern[{
    "ServerBase"->
      (
        _String?DirectoryQ|
        _String?(MatchQ[URLParse[#, "Scheme"], "file"|"http"]&)
        ),
    "ServerName"->_
    }];
localPacletServerPatOrDir=
  LocalPacletServerPattern|_String?DirectoryQ;
localPacletServer=
  MatchQ[LocalPacletServerPattern]


(* ::Subsubsection::Closed:: *)
(*PacletServerURL*)



PacletServerURL//Clear


PacletServerURL[serv:LocalPacletServerPattern]:=
  PacletSiteURL@
    FilterRules[serv,
      Options[PacletSiteURL]
      ];
PacletServerURL[serv_String?DirectoryQ]:=
  URLBuild[<|"Scheme"->"file", "Path"->FileNameSplit[serv]|>];
PacletServerURL[s_String?(KeyMemberQ[$PacletServers, #]&)]:=
  PacletSiteURL@$PacletServers[s];
PacletServerURL[]:=
  With[{res=
    If[Length@$PacletServers>0,
      Replace[PacletServerURL["Default"],
        _PacletServerURL:>PacletServerURL@First@$PacletServers
        ]
      ]
    },
    res/;StringQ@res
    ]


$PacletServerURL:=
  PacletServerURL@$PacletServer


(* ::Subsubsection::Closed:: *)
(*PacletServerDeploymentURL*)



PacletServerDeploymentURL//Clear


PacletServerDeploymentURL[server:LocalPacletServerPattern]:=
  PacletSiteURL@
    FilterRules[
      Flatten@{
        "ServerBase"->
          If[URLParse[PacletServerURL[server], "Scheme"]==="file", 
            CloudObject, 
            Lookup[server, "ServerBase"]
            ],
        Normal@server
        },
      Options[PacletSiteURL]
      ];
PacletServerDeploymentURL[s_String?DirectoryQ]:=
  Lookup[
    Import[PacletServerFile[s, "SiteConfig.wl"]],
    "SiteURL",
    $Failed
    ];
PacletServerDeploymentURL[s_String?(KeyMemberQ[$PacletServers, #]&)]:=
  PacletServerDeploymentURL@$PacletServers[s];
PacletServerDeploymentURL[]:=
  With[{res=
    If[Length@$PacletServers>0,
      Replace[PacletServerDeploymentURL["Default"],
        _PacletServerDeploymentURL:>PacletServerDeploymentURL@First@$PacletServers
        ]
      ]
    },
    res/;StringQ@res
    ]


(* ::Subsubsection::Closed:: *)
(*PacletServerFile*)



PacletServerFile[
  server:LocalPacletServerPattern,
  fileName:_String|{__String}|Nothing
  ]:=
  With[{u=URLBuild@Flatten@{PacletServerURL[server],fileName}},
    If[URLParse[u,"Scheme"]==="file",
      FileNameJoin@URLParse[u,"Path"],
      u
      ]
    ];
PacletServerFile[
  server:_String?DirectoryQ,
  fileName:_String|{__String}|Nothing
  ]:=
  FileNameJoin@Flatten@{server, fileName}
PacletServerDirectory[
  server:LocalPacletServerPattern|_String?DirectoryQ
  ]:=
  PacletServerFile[server, Nothing]


$PacletServerDirectory:=
  PacletServerDirectory@$PacletServer;


(* ::Subsubsection::Closed:: *)
(*PacletServerDataset*)



Options[PacletServerDataset]=
  {
    "DeployedServer"->
      True
    };
PacletServerDataset[
  server:LocalPacletServerPattern,
  ops:OptionsPattern[]
  ]:=
  PacletSiteInfoDataset@
    FilterRules[
      If[TrueQ@OptionValue["DeployedServer"],
        Prepend["ServerBase"->Automatic],
        Identity
        ]@
        Normal@server,
      Options[PacletSiteInfoDataset]
      ];


(* ::Subsubsection::Closed:: *)
(*PacletServerExposedPaclets*)



PacletServerExposedPaclets//Clear


PacletServerExposedPaclets[
  pacletSpecs:{___Association}
  ]:=
  Map[Normal,
    Select[
      SortBy[
        DeleteDuplicatesBy[
          Reverse@SortBy[ToExpression@StringSplit[#Version,"."]&]@
            Flatten@{pacletSpecs},
          #Name&
          ],
        #Name&
        ],
      !StringEndsQ[#Name,("_Part"~~NumberString)|"_Index"]&
      ]
    ];
PacletServerExposedPaclets[d_Dataset]:=
  PacletServerExposedPaclets@Normal@d;
PacletServerExposedPaclets[server:localPacletServerPatOrDir]:=
  PacletServerExposedPaclets@
    PacletSiteInfoDataset[
      PacletServerFile[server, "PacletSite.mz"]
      ]


$PacletServerExposedPaclets:=
  PacletServerExposedPaclets@$PacletServer


(* ::Subsubsection::Closed:: *)
(*PacletServerBundleSite*)



PacletServerBundleSite[
  server:localPacletServerPatOrDir
  ]:=
  With[{ps=PacletExecute["BundleSite", PacletServerDirectory[server]]},
    CopyFile[
      ps,
      PacletServerFile[server, "PacletSite.mz"],
      OverwriteTarget->True
      ]
    ]


(* ::Subsection:: *)
(*Build*)



(* ::Subsubsection::Closed:: *)
(*PacletMarkdownNotebook Bits*)



(* ::Subsubsubsection::Closed:: *)
(*pacletMarkdownNotebookMetadataSection*)



(* ::Subsubsubsubsection::Closed:: *)
(*pacletMarkdownNotebookMetadataAddCategory*)



pacletMarkdownNotebookMetadataAddCategory[a_, key_]:=
  If[KeyExistsQ[a, "Categories"],
    ReplacePart[a,
      "Categories":>
        DeleteCases["misc"]@DeleteDuplicates@
          Append[
            Flatten@StringSplit[Lookup[a, "Categories", {}], ","], 
            key
            ]
      ],
    Append[a, "Categories"->{key}]
    ]


(* ::Subsubsubsubsection::Closed:: *)
(*pacletMarkdownNotebookMetadataGetFileModificationDate*)



pacletMarkdownNotebookMetadataGetFileModificationDate[
  {name_, version_, old_}
  ]:=
  If[DateObjectQ[old],
    Max[{#, old}],
    #
    ]&@
    Quiet@
      Check[
        FileDate[
          FileNameJoin@{
            $BuildingPacletServerDirectory, 
            "Paclets", 
            name<>"-"<>version<>".paclet"
            }
          ],
        old
        ]


(* ::Subsubsubsubsection::Closed:: *)
(*pacletMarkdownNotebookMetadataSection*)



pacletMarkdownNotebookMetadataSection[a_]:=
  Cell[
    BoxData@ToBoxes@Association@Normal@
      Join[
        Which[
          StringStartsQ[a["Name"], "ServiceConnection_"],
            pacletMarkdownNotebookMetadataAddCategory[a, "ServiceConnections"],
          StringStartsQ[a["Name"], "Documentation_"],
            pacletMarkdownNotebookMetadataAddCategory[a, "Documentation"],
          StringStartsQ[a["Name"], "DeviceDriver_"],
            pacletMarkdownNotebookMetadataAddCategory[a, "DeviceDriver"],
          StringStartsQ[a["Name"], "ExampleData_"],
            pacletMarkdownNotebookMetadataAddCategory[a, "ExampleData"],
          StringStartsQ[a["Name"], "WordData_"],
            pacletMarkdownNotebookMetadataAddCategory[a, "WordData"],
          StringEndsQ[a["Name"], "_Index"],
            pacletMarkdownNotebookMetadataAddCategory[a, "DataIndices"],
          StringEndsQ[a["Name"], "_Part"~~NumberString],
            pacletMarkdownNotebookMetadataAddCategory[a, "DataParts"],
          StringContainsQ[a["Name"], "_"],
            pacletMarkdownNotebookMetadataAddCategory[a, 
              Quiet@Check[Pluralize@#, #<>"s"]&@
                StringSplit[a["Name"], "_"][[1]]],
          StringEndsQ[a["Name"], "Data"],
            pacletMarkdownNotebookMetadataAddCategory[a, "DataPaclets"],
          True,
            a
          ],
      <|
        "DisplayName"->
          pacletMarkdownNotebookMakeName[a["Name"]],
        "Modified"->
          pacletMarkdownNotebookMetadataGetFileModificationDate[
            Lookup[a, {"Name", "Version", "LastModified"}, Missing["NotAvailable"]]
            ]
        |>
      ],
    "Metadata",
    CellTags->"Metadata"
    ]


(* ::Subsubsubsection::Closed:: *)
(*pacletMarkdownNotebookNameCell*)



pacletMarkdownNotebookMakeName[s_String]:=
  Replace[StringSplit[s, "_"],
    {
      {n_}:>n,
      {
        k:"ServiceConnection"|"Documentation"|"DeviceDriver"|"ExampleData"|"WordData", 
        p_
        }:>
        p<>" ("<>k<>")",
      {p_, k:"Index"|_String?(StringStartsQ["Part"])}:>
        p<>" ("<>k<>")"
      }
    ];


pacletMarkdownNotebookNameCell[a_]:=
  Cell[
    pacletMarkdownNotebookMakeName@
      Lookup[a, "Name", "Unnamed Paclet"], 
    "Section",
    CellTags->"PacletName"
    ]


(* ::Subsubsubsection::Closed:: *)
(*pacletMarkdownNotebookNameStringCell*)



pacletMarkdownNotebookNameStringCell[a_]:=
  Cell[
    BoxData@ToBoxes@
      Lookup[a, "Name", $Failed], 
    "Text",
    CellTags->"PacletNameString"
    ]


(* ::Subsubsubsection::Closed:: *)
(*pacletMarkdownNotebookIcon*)



pacletMarkdownNotebookIcon[a_]:=
  Replace[
    Lookup[a, "Thumbnail", Lookup[a, "Icon"]],
    {
      s_String:>
        With[
          {
            nm=Lookup[a, "Name"],
            fp=URLParse[s]
            },
          Cell["!["<>nm<>"]("<>
            If[fp["Domain"]===None,
              "{filename}/img/"<>URLBuild[Prepend[URLParse[s, "Path"], nm]],
              s
              ]<>")", 
            "RawMarkdown",
            CellTags->"PacletIcon"
            ]
          ],
      _->Nothing
      }
    ];


(* ::Subsubsubsection::Closed:: *)
(*pacletMarkdownNotebookDownloadLink*)



pacletMarkdownNotebookDownloadLink[a_]:=
  Cell[
    TextData[
      ButtonBox["Download",
        BaseStyle->"Hyperlink",
          ButtonData->
          {
            URLBuild@{
              "Paclets",
              Lookup[a,"Name"]<>"-"<>
                Lookup[a,"Version"]<>".paclet"
              },
            None
            }
        ]
      ],
    "Text",
    CellTags->"DownloadLink"
    ]


(* ::Subsubsubsection::Closed:: *)
(*pacletMarkdownNotebookDescriptionText*)



pacletMarkdownNotebookDescriptionText[a_]:=
  Cell[Lookup[a,"Description",""],"Text",
    CellTags->"DescriptionText"
    ]


(* ::Subsubsubsection::Closed:: *)
(*pacletMarkdownNotebookInfoSection*)



pacletMarkdownNotebookInfoSectionValue[v_String]:=
  Which[
    With[{p=URLParse[v]},
      StringQ@p["Scheme"]&&
        StringQ@p["Domain"]
      ],
      With[{p=URLParse[v]},
        "["<>v<>"]("<>v<>")"
        ], 
    StringQ@Interpreter["EmailAddress"][v],
      With[{e=Interpreter["EmailAddress"][v]},
        "["<>StringTrim[StringSplit[v, "<"][[1]]]<>"]("<>"mailto:"<>e<>")"
        ],
    True,
      v
    ];
pacletMarkdownNotebookInfoSectionValue[v:_List]:=
  StringRiffle[v, ", "];


pacletMarkdownNotebookInfoSection[a_,thing_]:=
  With[{d=pacletMarkdownNotebookInfoSectionValue@Lookup[a, thing]},
    If[StringQ@d,
      Cell[
        CellGroupData[{
          Cell[thing, "Subsubsection", CellTags->{"Info", thing}],
          Cell[d, "Text"]
          }]
        ],
      Nothing
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*pacletMarkdownNotebookBasicInfoSection*)



$pacletMarkdownNotebookBasicInfoSectionKeys=
  {
    "Name", 
    "Version", 
    "Creator",
    "URL",
    "Publisher",
    "Support",
    "License",
    "GitHub"
    }


pacletMarkdownNotebookBasicInfoSection[a_]:=
  Cell[
    CellGroupData[Flatten@{
      Cell["Basic Information","Subsection"],
      Map[
        pacletMarkdownNotebookInfoSection[a, #]&,
        $pacletMarkdownNotebookBasicInfoSectionKeys
        ]
      }],
    CellTags->"BasicInformation"
    ]


(* ::Subsubsubsection::Closed:: *)
(*pacletMarkdownNotebookExtraInfoSection*)



$pacletMarkdownNotebookExtraInfoSectionKeys=
  {
    "WolframVersion", "MathematicaVersion",
    "SystemID",
    "Internal", "BuildNumber",
    "Qualifier", "Category"
    };


pacletMarkdownNotebookExtraInfoSection[a_]:=
  If[
    Length@
      Lookup[a, 
        $pacletMarkdownNotebookExtraInfoSectionKeys,
        Nothing
        ]>0,
    Cell[
      CellGroupData[{
        Cell["Extra Information","Subsection"],
        Sequence@@
          Map[
            pacletMarkdownNotebookInfoSection[a, #]&,
            $pacletMarkdownNotebookExtraInfoSectionKeys
            ]
        }],
      CellTags->"ExtraInformation"
      ],
    Cell[
      CellGroupData[
        {
          Cell["Extra Information", "Subsection"],
          Cell["This package provides no extra information", "Text"]
          }],
      CellTags->"ExtraInformation"
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*pacletMarkdownNotebookExtensionSection*)



pacletMarkdownNotebookExtensionGroup[a_?(KeyExistsQ[#, "Extensions"]&)]:=
    If[KeyMemberQ[a, "Extensions"],
      pacletMarkdownNotebookExtensionSection[a["Extensions"]],
      Cell[
        CellGroupData[
          {
            Cell["Extensions", "Subsection"],
            Cell["This package has no extensions", "Item", 
              CellTags->{"Info", "NoExtensions"}
              ]
            }
          ],
        CellTags->"Extensions"
        ]
      ]


pacletMarkdownNotebookExtensionSection[extensionData_]:=
  Block[{Internal`$ContextMarks=False},
    Cell[
      CellGroupData@
        Flatten@{
          Cell["Extensions", "Subsection"],
          KeyValueMap[
            Cell@
              CellGroupData[Flatten@{
                Cell[#, "Subsubsection", CellTags->{"Info", #}],
                Replace[
                  Replace[Normal@#2,
                    {
                      ((Prepend|Append)->_):>Nothing,
                      (k_->v:Except[{__String}, _List]):>
                        Cell[
                          CellGroupData[
                            Prepend[
                              Cell[
                                If[MatchQ[k, _Symbol], SymbolName[k], ToString[k]], 
                                "Item",
                                CellTags->{"Info", "Line"}
                                ]
                              ]@
                              Map[
                                Cell[
                                  Replace[#, 
                                    {
                                      (sk_->sv_):>
                                        If[MatchQ[sk, _Symbol], 
                                          SymbolName[sk], ToString[sk]]<>": "<>
                                          ToString@
                                            Replace[sv, str:{__String}:>StringRiffle[str, ", "]],
                                      e_:>ToString[e]
                                      }
                                    ], 
                                  "Subitem",
                                  CellTags->{"Info", "Line"}
                                  ]&,
                                v
                                ]
                            ]
                          ],
                      (k_->v_):>
                        Cell[
                          If[MatchQ[k, _Symbol], SymbolName[k], ToString[k]]<>": "<>
                          ToString[Replace[v, str:{__String}:>StringRiffle[str, ", "]]], 
                          "Item",
                          CellTags->{"Info", "Line"}
                          ]
                      },
                    1],
                  {}:>
                    Cell["This extension has no extra parameters", "Item",
                      CellTags->{"Info", "Line"}
                      ]
                  ]
                }]&,
            KeyDrop[
              extensionData,
              {"PacletServer"}
              ]
            ]
          },
      CellTags->"Extensions"
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*PacletMarkdownNotebook*)



(* ::Text:: *)
(*Generates a basic notebook for creating a paclet page*)



PacletMarkdownNotebook//Clear


PacletMarkdownNotebook[infAss_Association]:=
  With[
    {
      a=
        Join[
          infAss,
          Association@
            Fold[
              Association[
                Normal@
                  Lookup[#, #2, <||>]/.
                    (s_Symbol?(Function[Null, Context[#]=!="System`", HoldFirst]):>
                      SymbolName[s])
                ]&,
              infAss,
              {"Extensions", "PacletServer"}
              ]
          ]
      },
    Notebook[
      {
        pacletMarkdownNotebookMetadataSection@
          KeyDrop[a, "URL"],
        Cell@CellGroupData@
          Flatten@{
            pacletMarkdownNotebookNameCell[a],
            pacletMarkdownNotebookIcon[a],
            pacletMarkdownNotebookDownloadLink[a],
            pacletMarkdownNotebookDescriptionText[a],
            Prepend[Cell["","PageBreak"]]@
            Riffle[
              {
                pacletMarkdownNotebookBasicInfoSection[a],
                pacletMarkdownNotebookExtraInfoSection[a],
                pacletMarkdownNotebookExtensionGroup[a]
                },
            Cell["","PageBreak"]
            ]
          }
        },
      StyleDefinitions->FrontEnd`FileName[Evaluate@{$PackageName,"MarkdownNotebook.nb"}]
      ]
    ];
PacletMarkdownNotebook[p_PacletManager`Paclet]:=
  With[{a=PacletInfoAssociation@p},
    PacletMarkdownNotebook[a]
    ];
PacletMarkdownNotebook[f_String?FileExistsQ, a_, regen_:Automatic]:=
  PacletMarkdownNotebookUpdate[f, a, regen];
PacletMarkdownNotebook[f_String, a_, regen_:Automatic]:=
  With[{nb=PacletMarkdownNotebook[a]},
    exportNBIfChanges[f, nb, regen]
    ]


(* ::Subsubsubsection::Closed:: *)
(*exportNBIfChanges*)



exportNBIfChanges[f_, nb_, regen_]:=
    Switch[nb,
      _Notebook,
        If[!DirectoryQ@DirectoryName@f,
          CreateDirectory[DirectoryName@f,
            CreateIntermediateDirectories->True
            ]
          ];
        If[FileExistsQ@f,
          If[TrueQ[regen]||checkNBEquiv[f, nb],
            Export[f,nb]
            ],
          Export[f,nb]
          ],
      _,
        $Failed
      ]


(* ::Subsubsubsection::Closed:: *)
(*checkNBEquiv*)



checkNBEquiv[f_, nb_]:=
  Module[
    {
      a=Get[f][[;;1]], 
      b=nb[[;;1]]
      },
    a=NotebookTools`FlattenCellGroups[a]/.
      {
        ((ExpressionUUID|CellID)->_):>Sequence@@{},
        (CellTags->_):>Sequence@@{}
        };
    b=NotebookTools`FlattenCellGroups[b]/.
      {
        ((ExpressionUUID|CellID)->_):>Sequence@@{},
        (CellTags->_):>Sequence@@{}
        };
    a=DeleteCases[a, Cell[CellGroupData[{}, ___]], {2}];
    b=DeleteCases[b, Cell[CellGroupData[{}, ___]], {2}];
    a=!=b
    ]


(* ::Subsubsection::Closed:: *)
(*PacletMarkdownNotebookUpdate*)



(* ::Text:: *)
(*Updates the previous notebook*)



$killFields=
  {
    "Name","Version","BuildNumber",
    "Qualifier","WolframVersion",
    "SystemID", "SystemIDs",
    "Description","Category",
    "Creator","Publisher","Support",
    "Internal","Location","Thumbnail",
    "ExportOptions"
    };


PacletMarkdownNotebookUpdate//Clear


PacletMarkdownNotebookUpdate[notebook_Notebook,infAss_]:=
  Module[
    {
      nb=notebook,
      a=
        Join[
          infAss,
          Association@
            Fold[
              Lookup[#, #2, <||>]&,
              infAss,
              {"Extensions", "PacletServer"}
              ]
          ]
      },
    nb=
      DeleteCases[nb, 
        Cell[___, CellTags->{"Info", ___}, ___], \[Infinity]];
    nb=
      ReplaceAll[nb,
        c:Cell[__, CellTags->"PacletName", ___]:>
          With[{baseCell=pacletMarkdownNotebookNameCell[a]},
            If[StringQ@c[[2]],
              ReplacePart[baseCell, 2->c[[2]]],
              Delete[baseCell, 2]
              ]
            ]
        ];
    nb=
      ReplaceAll[nb,
        c:Cell[__, CellTags->"PacletNameString", ___]:>
          With[
            {
              baseCell=
                pacletMarkdownNotebookNameStringCell[a]
              },
            If[StringQ@c[[2]],
              ReplacePart[baseCell, 2->c[[2]]],
              Delete[baseCell, 2]
              ]
            ]
        ];
    nb=
      ReplaceAll[nb,
        c:Cell[__, CellTags->"PacletIcon", ___]:>
          With[{baseCell=pacletMarkdownNotebookIcon[a]},
            If[StringQ@c[[2]],
              ReplacePart[baseCell, 2->c[[2]]],
              Delete[baseCell, 2]
              ]
            ]
        ];
    nb=
      ReplaceAll[nb,
        Cell[BoxData[e_],"Metadata",___]:>
          pacletMarkdownNotebookMetadataSection@
            Merge[
              {
                KeyDrop[ToExpression[e], $killFields], 
                a
                },
              Last
              ]
        ];
    nb=
      ReplaceAll[nb,
        Cell[___,CellTags->"DownloadLink",___]:>
          pacletMarkdownNotebookDownloadLink[a]
        ];
    nb=
      ReplaceAll[nb,
        Cell[___,CellTags->"DescriptionText",___]:>
          pacletMarkdownNotebookDescriptionText[a]
        ];
    nb=
      ReplaceAll[nb,
        Cell[
          CellGroupData[
            {
              Cell[___,CellTags->"BasicInformation",___],
              ___
              }, 
            ___
            ],
          ___  
          ]|Cell[___, CellTags->"BasicInformation", ___]:>
          pacletMarkdownNotebookBasicInfoSection[a]
        ];
    nb=
      ReplaceAll[nb,
        Cell[
          CellGroupData[{
            Cell[___,CellTags->"ExtraInformation",___],
            ___
            }, ___],
          ___  
          ]|Cell[___,CellTags->"ExtraInformation",___]:>
          pacletMarkdownNotebookExtraInfoSection[a]
        ];
    (*nb=
			DeleteCases[nb,
				Cell[
					CellGroupData[{
						Cell[___,
							CellTags\[Rule]
								Except[
									#|{#..}&[
										Alternatives@@
											Join[
												{
													"DescriptionText",
													"DownloadLink",
													"BasicInformation",
													"ExtraInformation",
													"Info",
	
													},
												Keys[a]
												]
										]
									],
							___
							],
						___
						},___],
					___
					],
				\[Infinity]
				];*)
    nb=
      ReplaceAll[nb,
        Cell[
          CellGroupData[{
            Cell[___,
              CellTags->"Extensions",
              ___]
            },___
            ],
          ___
          ]|Cell[___,CellTags->"Extensions",___]:>
          pacletMarkdownNotebookExtensionSection[a["Extensions"]]
        ];
    nb
    ];
PacletMarkdownNotebookUpdate[f_String?FileExistsQ,a_,regen_:Automatic]:=
  Module[
    {
      old=Get[f],
      nb
      },
    If[MatchQ[old, _Notebook],
      nb = PacletMarkdownNotebookUpdate[old, a];
      exportNBIfChanges[f, nb, regen],
      $Failed
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*ExportPacletMarkdownNotebook*)



ExportPacletMarkdownNotebook[out_, params_, regen_:Automatic]:=
  Module[
    {
      fdate1=If[FileExistsQ@out, FileDate[out], None],
      fdate2
      },
    PacletMarkdownNotebook[out, params, regen];
    fdate2=FileDate[out];
    If[fdate1===None||fdate1<fdate2,
      Function[NotebookMarkdownSave[#];NotebookClose[#]]@
        NotebookOpen[out,Visible->False]
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*PacletServerInitialize*)



PacletServerInitialized[server_]:=
  With[{d=PacletServerDirectory[server]},
    AllTrue[{d,
      FileNameJoin@{d,"content"},
      FileNameJoin@{d,"SiteConfig.wl"}
      },
      FileExistsQ
      ]
    ];
$PacletServerInitialized:=
  PacletServerInitialized@$PacletServer


PacletServerInitialize//Clear


PacletServerInitialize[server:localPacletServerPatOrDir]:=
  If[!PacletServerInitialized@server,
    With[{d=PacletServerDirectory@server},
      If[!DirectoryQ@d,  
        CreateDirectory[d, CreateIntermediateDirectories->True]
        ];
      With[
        {
          tempDir=
            PackageFilePath["Resources", "Templates", "SiteBuilder", "PacletServer"]
          },
        Map[
          With[
            {
              tf=FileNameJoin@{d,FileNameDrop[#,FileNameDepth[tempDir]]}
              },
            If[!FileExistsQ@tf,
              If[DirectoryQ@#,
                CopyDirectory[#, tf],
                CopyFile[#, tf]
                ]
              ]
            ]&,
          FileNames["*", tempDir, \[Infinity]]
          ];
        ]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*RegeneratePacletPages*)



(* ::Subsubsubsection::Closed:: *)
(*copyThumbnailFromPaclet*)



copyThumbnailFromPaclet[pacF_, ico_, imgDir_]:=
  If[StringQ@ico&&FileExistsQ@pacF,
    Module[
      {
        outpath=FileNameJoin@Flatten@{imgDir, URLParse[ico, "Path"]},
        icoFile=FileNameJoin@Prepend[URLParse[ico, "Path"], FileBaseName[pacF]],
        icoImg
        },
      icoImg=
          Quiet[
            Import[pacF,
              {"ZIP", icoFile, "String"}
              ],
            Import::nffil
            ];
      If[StringQ@icoImg,
        If[!DirectoryQ@DirectoryName@outpath,
          CreateDirectory[DirectoryName@outpath,
            CreateIntermediateDirectories->True
            ]
          ];
        Export[outpath, icoImg, "String"]
        ]
      ]
    ];


copyThumbnailFromPaclet1[pacF_, ico_, imgDir_]:=
  Module[{tmp},
  (* Copy in Thumbnail file *)
    If[FileExistsQ[pacF]&&StringQ@ico,
      If[!DirectoryQ@imgDir,
        CreateDirectory[imgDir,
          CreateIntermediateDirectories->True
          ]
        ];
      tmp=CreateDirectory[];
        Replace[
          ExtractArchive[
            pacF,
            tmp,
            FileNameJoin@Prepend[URLParse[ico, "Path"], "*"],
            CreateIntermediateDirectories->True
            ],
          {f_, ___}:>
            With[{exp=FileNameJoin@Flatten@{imgDir, URLParse[ico, "Path"]}},
              If[!DirectoryQ@DirectoryName@exp,
                CreateDirectory[DirectoryName@exp, 
                  CreateIntermediateDirectories->True]
                ];
              CopyFile[
                f, 
                FileNameJoin@Flatten@{imgDir, URLParse[ico, "Path"]},
                OverwriteTarget->True
                ]
              ]
          ];
      DeleteDirectory[tmp, DeleteContents->True]
      ]
    ];


(* ::Subsubsubsection::Closed:: *)
(*RegeneratePacletPages*)



RegeneratePacletPages[server_, servDir_, pacletsDir_, siteData_, 
  mon_, regen_
  ]:=
  Module[
    {
      thm,
      nbout, pacF,
      ico, imgDir,
      siteDS
      },
    thm=WebSiteFindTheme[servDir, "DownloadTheme"->True];
    siteDS=
      SortBy[
        Association/@siteData,
        {#["Name"]&, -1*ToExpression@StringSplit[#["Version"], "-"]&}
        ];
    siteDS=DeleteDuplicatesBy[siteDS, #["Name"]&];
    If[mon,
      Function[Null,
        Monitor[#, 
          If[StringQ@md,
            Internal`LoadingPanel[TemplateApply["Generating ``", md]],
            ""
            ]
          ],
        HoldAll
        ],
      Identity
      ]@
      Block[{md, nb},
        nbout=PacletServerFile[server, {"content","posts",#Name<>".nb"}];
        pacF=
          FileNameJoin@
            {pacletsDir, #Name<>"-"<>#Version<>".paclet"};
        ico=Lookup[#, "Thumbnail", Lookup[#, "Icon"]];
        imgDir=PacletServerFile[server, {"content", "img", #Name}];
        (* Copy in Thumbnail file *)
        copyThumbnailFromPaclet[pacF, ico, imgDir];
        md=nbout;
        (* Ensure directory *)
        If[!DirectoryQ@DirectoryName@nbout,
          CreateDirectory[DirectoryName@nbout, 
            CreateIntermediateDirectories->True]
          ];
        (* Copy in potential template *)
        If[
          !FileExistsQ@nbout&&
            FileExistsQ@FileNameJoin@{thm, "templates", "PacletPage.nb"},
          CopyFile[
            FileNameJoin@{thm, "templates", "PacletPage.nb"},
            nbout
            ]
          ];
        (* Create notebook and export *)
        ExportPacletMarkdownNotebook[
          nbout,
          Join[
            <|
              "Title"->Lookup[#,"Name","Unnamed Paclet"],
              "Categories"->"misc",
              "Slug"->Automatic,
              "Authors"->
                StringTrim@
                  Map[
                    StringSplit[#, "@"|"<"][[1]]&,
                    StringSplit[Lookup[#,"Creator",""], ","]
                    ],
              "Tags"->StringSplit[Lookup[#,"Keywords",""],","]
              |>,
            #
            ],
          regen
          ];
        Internal`WithLocalSettings[
          nb=NotebookOpen[nbout,Visible->False],
          NotebookMarkdownSave[nb],
          NotebookClose[nb]
          ]
        ]&/@siteDS
      ];


End[];



