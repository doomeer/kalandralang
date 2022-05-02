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
%token BUY ILVL WITH FRACTURED FOR CRAFT ECHO SHOW SHOW_MOD_POOL SHOW_UNVEIL_MOD_POOL
%token SHAPER ELDER CRUSADER HUNTER REDEEMER WARLORD EXARCH EATER SYNTHESIZED
%token IF THEN ELSE UNTIL REPEAT WHILE DO GOTO STOP SET_ASIDE SWAP USE_IMPRINT GAIN HAS
%token UNVEIL
%token TIER
%token PREFIX_COUNT NO_PREFIX OPEN_PREFIX FULL_PREFIXES
%token SUFFIX_COUNT NO_SUFFIX OPEN_SUFFIX FULL_SUFFIXES
%token AFFIX_COUNT NO_AFFIX OPEN_AFFIX FULL_AFFIXES
%token LPAR RPAR LBRACE RBRACE
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

buy_arguments:
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
  { node @@ Has (Id.make $2) }
| PREFIX_COUNT INT
  { node @@ Prefix_count ($2, $2) }
| PREFIX_COUNT INT DOT_DOT INT
  { node @@ Prefix_count ($2, $4) }
| NO_PREFIX
  { node @@ Prefix_count (0, 0) }
| OPEN_PREFIX
  { node @@ Open_prefix }
| FULL_PREFIXES
  { node @@ Full_prefixes }
| SUFFIX_COUNT INT
  { node @@ Suffix_count ($2, $2) }
| SUFFIX_COUNT INT DOT_DOT INT
  { node @@ Suffix_count ($2, $4) }
| NO_SUFFIX
  { node @@ Suffix_count (0, 0) }
| OPEN_SUFFIX
  { node @@ Open_suffix }
| FULL_SUFFIXES
  { node @@ Full_suffixes }
| AFFIX_COUNT INT
  { node @@ Affix_count ($2, $2) }
| AFFIX_COUNT INT DOT_DOT INT
  { node @@ Affix_count ($2, $4) }
| NO_AFFIX
  { node @@ Affix_count (0, 0) }
| OPEN_AFFIX
  { node @@ Open_affix }
| FULL_AFFIXES
  { node @@ Full_affixes }
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
| BUY buy_arguments
  { node @@ Simple (Buy (AST.make_buy $2)) }
| CURRENCY
  { node @@ Simple (Apply $1) }
| FOSSIL plus_fossils
  { node @@ Simple (Apply (Fossils ($1 :: $2))) }
| CRAFT STRING
  { node @@ Simple (Apply (Craft (Id.make $2))) }
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

instruction:
| simple_instruction
  { $1 }
| IF condition THEN simple_instruction
  { node @@ If ($2, $4, None) }
| IF condition THEN simple_instruction ELSE simple_instruction
  { node @@ If ($2, $4, Some $6) }
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
