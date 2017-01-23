module Parser.Expose exposing (..)

import Combine exposing (..)
import Combine.Char exposing (..)
import Parser.Tokens exposing (..)
import Parser.Types exposing (..)
import Parser.Util exposing (moreThanIndentWhitespace)


exposeDefinition : Parser State a -> Parser State (Exposure a)
exposeDefinition p =
    choice
        [ moreThanIndentWhitespace *> exposingToken *> maybe moreThanIndentWhitespace *> exposeListWith p
        , succeed None
        ]


exposable : Parser State Expose
exposable =
    choice
        [ typeExpose
        , infixExpose
        , definitionExpose
        ]


infixExpose : Parser State Expose
infixExpose =
    InfixExpose <$> parens (while ((/=) ')'))


typeExpose : Parser State Expose
typeExpose =
    succeed TypeExpose
        <*> typeName
        <*> (maybe moreThanIndentWhitespace *> exposeListWith typeName)


exposingListInner : Parser State b -> Parser State (Exposure b)
exposingListInner p =
    or ((always Parser.Types.All) <$> (maybe moreThanIndentWhitespace *> string ".." <* maybe moreThanIndentWhitespace))
        (Parser.Types.Explicit <$> sepBy (char ',') (maybe moreThanIndentWhitespace *> p <* maybe moreThanIndentWhitespace))


exposeListWith : Parser State b -> Parser State (Exposure b)
exposeListWith p =
    parens (exposingListInner p)


definitionExpose : Parser State Expose
definitionExpose =
    DefinitionExpose <$> functionOrTypeName