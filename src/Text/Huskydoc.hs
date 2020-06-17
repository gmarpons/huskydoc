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
{-# LANGUAGE OverloadedStrings #-}
{-|
Module      :  Text.Huskydoc
Copyright   :  © 2016 Albert Krewinkel
License     :  ISC

Maintainer  :  Albert Krewinkel <tarleb@zeitkraut.de>
Stability   :  experimental
Portability :  portable

Asciidoc parser.
-}
module Text.Huskydoc
  ( parseToPandoc
  ) where

import Data.Bifunctor ( second )
import Data.Text ( Text )
import Data.Void
import Text.Huskydoc.Document ( readAsciidoc )
import Text.Huskydoc.Pandoc ( convertDocument )
import Text.Megaparsec ( ParseErrorBundle )
import Text.Pandoc.Definition ( Pandoc )

parseToPandoc :: Text -> Either (ParseErrorBundle Text Void) Pandoc
parseToPandoc = second convertDocument . readAsciidoc
