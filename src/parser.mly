%{
  open AST

  let node node =
    {
      loc = Parsing.symbol_start_pos (), Parsing.symbol_end_pos ();
      node;
    }
%}

%token COLON AND OR NOT DOT_DOT TRUE FALSE EOF
%token PLUS MINUS STAR SLASH
%token ASSERT BUY EXACT NORMAL MAGIC RARE
%token ILVL WITH FRACTURED FOR CRAFT ECHO SHOW SHOW_MOD_POOL SHOW_UNVEIL_MOD_POOL
%token SHAPER ELDER CRUSADER HUNTER REDEEMER WARLORD EXARCH EATER SYNTHESIZED
%token IF THEN ELSE UNTIL REPEAT WHILE DO GOTO STOP SET_ASIDE SWAP USE_IMPRINT GAIN
%token HAS HAS_MOD HAS_GROUP IS_BASE
%token UNVEIL
%token TIER
%token PREFIX_COUNT NO_PREFIX OPEN_PREFIX FULL_PREFIXES
%token SUFFIX_COUNT NO_SUFFIX OPEN_SUFFIX FULL_SUFFIXES
%token AFFIX_COUNT NO_AFFIX OPEN_AFFIX FULL_AFFIXES
%token LPAR RPAR LBRACE RBRACE LBRACKET RBRACKET
%token RECOMBINE
%token <AST.comparison_operator> COMPARISON_OPERATOR
%token <AST.currency> CURRENCY
%token <Fossil.t> FOSSIL
%token <string> STRING LABEL
%token <int> INT

%left OR
%left AND
%nonassoc NOT
%left PLUS MINUS
%left STAR SLASH
%nonassoc unary_minus

%type <AST.t> program
%start program
%%

amount:
| INT CURRENCY amount
  { ($1, $2) :: $3 }
| INT CURRENCY
  { [ $1, $2 ] }

rarity:
| NORMAL { Item.Normal }
| MAGIC { Item.Magic }
| RARE { Item.Rare }

influence:
| SHAPER { Influence.SEC Shaper }
| ELDER { Influence.SEC Elder }
| CRUSADER { Influence.SEC Crusader }
| HUNTER { Influence.SEC Hunter }
| REDEEMER { Influence.SEC Redeemer }
| WARLORD { Influence.SEC Warlord }
| EXARCH { Influence.Exarch }
| EATER { Influence.Eater }
| SYNTHESIZED { Influence.Synthesized }
| FRACTURED { Influence.Fractured }

buy_arguments:
| EXACT buy_arguments
  { BA_exact :: $2 }
| rarity buy_arguments
  { BA_rarity $1 :: $2 }
| influence buy_arguments
  { BA_influence $1 :: $2 }
| STRING buy_arguments
  { BA_base (Id.make $1) :: $2 }
| ILVL INT buy_arguments
  { BA_ilvl $2 :: $3 }
| WITH STRING buy_arguments
  { BA_with { modifier = Id.make $2; fractured = false } :: $3 }
| WITH FRACTURED STRING buy_arguments
  { BA_with { modifier = Id.make $3; fractured = true } :: $4 }
| FOR amount buy_arguments
  { BA_for $2 :: $3 }
|
  { [] }

arithmetic_expression:
| INT
  { node @@ Int $1 }
| MINUS arithmetic_expression %prec unary_minus
  { node @@ Neg $2 }
| arithmetic_expression PLUS arithmetic_expression
  { node @@ Binary_arithmetic_operator ($1, Add, $3) }
| arithmetic_expression MINUS arithmetic_expression
  { node @@ Binary_arithmetic_operator ($1, Sub, $3) }
| arithmetic_expression STAR arithmetic_expression
  { node @@ Binary_arithmetic_operator ($1, Mul, $3) }
| arithmetic_expression SLASH arithmetic_expression
  { node @@ Binary_arithmetic_operator ($1, Div, $3) }
| PREFIX_COUNT
  { node @@ (Prefix_count: AST.arithmetic_expression_node) }
| SUFFIX_COUNT
  { node @@ (Suffix_count: AST.arithmetic_expression_node) }
| AFFIX_COUNT
  { node @@ (Affix_count: AST.arithmetic_expression_node) }
| TIER STRING
  { node @@ Tier (Id.make $2) }
| LPAR arithmetic_expression RPAR
  { $2 }
| LBRACKET condition RBRACKET
  { node @@ Int_of_bool $2 }

condition:
| TRUE
  { node @@ True }
| FALSE
  { node @@ False }
| NOT condition
  { node @@ Not $2 }
| condition AND condition
  { node @@ And ($1, $3) }
| condition OR condition
  { node @@ Or ($1, $3) }
| arithmetic_expression COMPARISON_OPERATOR arithmetic_expression
  { node @@ Comparison ($1, $2, $3) }
| arithmetic_expression COMPARISON_OPERATOR arithmetic_expression
  COMPARISON_OPERATOR arithmetic_expression
  { node @@ Double_comparison ($1, $2, $3, $4, $5) }
| HAS STRING
  { node @@ Has { fractured = false; id = Id.make $2 } }
| HAS_MOD STRING
  { node @@ Has_mod { fractured = false; id = Id.make $2 } }
| HAS_GROUP STRING
  { node @@ Has_group { fractured = false; id = Id.make $2 } }
| HAS FRACTURED STRING
  { node @@ Has { fractured = true; id = Id.make $3 } }
| HAS_MOD FRACTURED STRING
  { node @@ Has_mod { fractured = true; id = Id.make $3 } }
| HAS_GROUP FRACTURED STRING
  { node @@ Has_group { fractured = true; id = Id.make $3 } }
| influence
  { node @@ Has_influence $1 }
| IS_BASE STRING
  { node @@ Is_base (Id.make $2) }
| PREFIX_COUNT INT
  { node @@ C_prefix_count ($2, $2) }
| PREFIX_COUNT INT DOT_DOT INT
  { node @@ C_prefix_count ($2, $4) }
| NO_PREFIX
  { node @@ C_prefix_count (0, 0) }
| OPEN_PREFIX
  { node @@ Open_prefix }
| FULL_PREFIXES
  { node @@ Full_prefixes }
| SUFFIX_COUNT INT
  { node @@ C_suffix_count ($2, $2) }
| SUFFIX_COUNT INT DOT_DOT INT
  { node @@ C_suffix_count ($2, $4) }
| NO_SUFFIX
  { node @@ C_suffix_count (0, 0) }
| OPEN_SUFFIX
  { node @@ Open_suffix }
| FULL_SUFFIXES
  { node @@ Full_suffixes }
| AFFIX_COUNT INT
  { node @@ C_affix_count ($2, $2) }
| AFFIX_COUNT INT DOT_DOT INT
  { node @@ C_affix_count ($2, $4) }
| NO_AFFIX
  { node @@ C_affix_count (0, 0) }
| OPEN_AFFIX
  { node @@ Open_affix }
| FULL_AFFIXES
  { node @@ Full_affixes }
| NORMAL
  { node @@ Normal }
| MAGIC
  { node @@ Magic }
| RARE
  { node @@ Rare }
| LPAR condition RPAR
  { $2 }

plus_fossils:
| PLUS FOSSIL plus_fossils
  { $2 :: $3 }
|
  { [] }

or_unveil_mods:
| OR STRING or_unveil_mods
  { Id.make $2 :: $3 }
|
  { [] }

unveil_mods:
| STRING or_unveil_mods
  { Id.make $1 :: $2 }
|
  { [] }

simple_instruction:
| LABEL COLON
  { node @@ Label (AST.Label.make $1) }
| GOTO LABEL
  { node @@ Simple (Goto (AST.Label.make $2)) }
| STOP
  { node @@ Simple Stop }
| ASSERT condition
  { node (Simple (Assert ($2, None))) }
| ASSERT condition COLON STRING
  { node @@ Simple (Assert ($2, Some $4)) }
| BUY buy_arguments
  { node @@ Simple (Buy (AST.make_buy $2)) }
| CURRENCY
  { node @@ Simple (Apply $1) }
| FOSSIL plus_fossils
  { node @@ Simple (Apply (Fossils ($1 :: $2))) }
| CRAFT STRING
  { node @@ Simple (Apply (Craft (Id.make $2))) }
| RECOMBINE
  { node @@ Simple Recombine }
| SET_ASIDE
  { node @@ Simple Set_aside }
| SWAP
  { node @@ Simple Swap }
| USE_IMPRINT
  { node @@ Simple Use_imprint }
| GAIN amount
  { node @@ Simple (Gain $2) }
| ECHO STRING
  { node @@ Simple (Echo $2) }
| SHOW
  { node @@ Simple Show }
| SHOW_MOD_POOL
  { node @@ Simple Show_mod_pool }
| SHOW_UNVEIL_MOD_POOL
  { node @@ Simple Show_unveil_mod_pool }
| LBRACE instructions RBRACE
  { $2 }
| UNVEIL unveil_mods
  { node @@ Simple (Unveil $2) }

if_else:
| IF condition THEN simple_instruction
  { node @@ If ($2, $4, None) }
| IF condition THEN simple_instruction ELSE simple_instruction
  { node @@ If ($2, $4, Some $6) }
| IF condition THEN simple_instruction ELSE if_else
  { node @@ If ($2, $4, Some $6) }

instruction:
| simple_instruction
  { $1 }
| if_else
  { $1 }
| UNTIL condition DO simple_instruction
  { node @@ Until ($2, $4) }
| WHILE condition DO simple_instruction
  { node @@ While ($2, $4) }
| REPEAT simple_instruction UNTIL condition
  { node @@ Repeat ($2, $4) }
| UNVEIL unveil_mods ELSE simple_instruction
  { node @@ Unveil_else ($2, $4) }

instructions:
| instruction instructions
  { node @@ Seq ($1, $2) }
|
  { node @@ Noop }

program:
| instructions EOF
  { $1 }
