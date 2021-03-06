{-
Copyright (c) 2016 Albert Krewinkel

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{- |
Module      :  Text.Huskydoc.Pandoc
Copyright   :  © 2016 Albert Krewinkel
License     :  ISC

Maintainer  :  Albert Krewinkel <tarleb@zeitkraut.de>
Stability   :  experimental
Portability :  portable

Converters from huskydoc to pandoc types
-}
module Text.Huskydoc.Pandoc
  ( convertDocument
  , convertBlocks
  , convertInlines
  ) where

import Prelude hiding ( concat, foldr )
import Data.Foldable ( foldl', foldr )
import Data.Function ( (&) )
import Data.Functor ( (<&>) )
import Data.Text ( Text, concat )
import GHC.Exts ( IsList (..) )
import Text.Huskydoc.Attributes ( attribValue )
import Text.Huskydoc.Patterns
import Text.Pandoc.Definition (Pandoc)
import qualified Text.Pandoc.Builder as Pandoc

-- | Convert a huskydoc AST into an pandoc AST
convertDocument :: Document -> Pandoc
convertDocument (Document Metadata{..} bs) =
  Pandoc.setTitle (convertInlines metadataTitle)
  . maybe id (Pandoc.setAuthors . (:[]) . convertInlineElement . Str)
          metadataAuthor
  . Pandoc.doc
  . convertBlocks $ bs

-- | Convert huskydoc blocks into pandoc blocks
convertBlocks :: Blocks -> Pandoc.Blocks
convertBlocks = foldr ((<>) . convertBlockElement) mempty . fromBlocks

-- | Convert a single huskydoc block element into pandoc blocks
convertBlockElement :: BlockElement -> Pandoc.Blocks
convertBlockElement = \case
  (RichSectionTitle attrs lvl inlns) -> Pandoc.headerWith
                                          (convertAttributes attrs)
                                          lvl
                                          (convertInlines inlns)
  (RichSource attrs srcLines)  -> let addEol = (<> "\n") . fromSourceLine
                                      attr = convertAttributes attrs
                                  in srcLines <&> addEol & concat
                                       & Pandoc.codeBlockWith attr
  (BulletList lst)         -> Pandoc.bulletList . map convertListItem $ lst
  (HorizontalRule)         -> Pandoc.horizontalRule
  (OrderedList lst)        -> Pandoc.orderedList . map convertListItem $ lst
  (Paragraph inlns)        -> Pandoc.para (convertInlines inlns)
  (Table _ rows _)         -> let pandocRows = map convertRows rows
                                  headers = map (const mempty) (head pandocRows)
                              in Pandoc.simpleTable headers pandocRows
  _                        -> mempty

-- | Convert a list item to a list of pandoc blocks
convertListItem :: ListItem -> Pandoc.Blocks
convertListItem =
  mconcat . map convertBlockElement . toList . fromBlocks . fromListItem

-- | Convert rows
convertRows :: TableRow -> [Pandoc.Blocks]
convertRows = map convertTableCell . fromTableRow

-- | Convert a table cell to pandoc blocks
convertTableCell :: TableCell -> Pandoc.Blocks
convertTableCell = convertBlocks . tableCellContent

-- | Convert huskydoc inlines into pandoc inlines
convertInlines :: Inlines -> Pandoc.Inlines
convertInlines = foldr ((<>) . convertInlineElement) mempty . fromInlines

convertInlineElement :: InlineElement -> Pandoc.Inlines
convertInlineElement = \case
  (RichImage attrs src) -> Pandoc.imageWith
                             (convertAttributes attrs)
                             src
                             (maybe mempty id $ attribValue attrs "title")
                             (maybe mempty Pandoc.str $
                              attribValue attrs "alt")
  (Emphasis inlns)    -> Pandoc.emph . convertInlines $ inlns
  (HardBreak)         -> Pandoc.linebreak
  (Link ref desc)     -> Pandoc.link ref mempty (convertInlines desc)
  (Monospaced inlns)  -> Pandoc.code . extractText $ inlns
  (SoftBreak)         -> Pandoc.softbreak
  (Space)             -> Pandoc.space
  (Str txt)           -> Pandoc.str txt
  (Strong   inlns)    -> Pandoc.strong . convertInlines $ inlns
  (Subscript is)      -> Pandoc.subscript . convertInlines $ is
  (Superscript is)    -> Pandoc.superscript . convertInlines $ is
  _                   -> mempty -- suppress GHC warnings

-- | Convert huskydoc attributes to pandoc attr
convertAttributes :: Attributes -> Pandoc.Attr
convertAttributes attributes =
  let ident = maybe "" id $ attribValue attributes "id"
      classes = []
  in (ident, classes, mempty)

-- | Convert inlines to raw text
extractText :: Inlines -> Text
extractText = foldl' step mempty . fromInlines
  where
    step :: Text -> InlineElement -> Text -- -> Text
    step acc inlns = mappend acc $
      case inlns of
        (Emphasis inlns')    -> extractText inlns'
        (HardBreak)          -> "\n"
        (Link _ desc)        -> extractText desc
        (Monospaced inlns')  -> extractText inlns'
        (SoftBreak)          -> " "
        (Space)              -> " "
        (Str txt)            -> txt
        (Strong inlns')      -> extractText inlns'
        (Subscript inlns')   -> extractText inlns'
        (Superscript inlns') -> extractText inlns'
        _                    -> mempty
