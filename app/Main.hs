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
Module      :  Main
Copyright   :  © 2016 Albert Krewinkel
License     :  ISC

Maintainer  :  Albert Krewinkel <tarleb@zeitkraut.de>
Stability   :  experimental
Portability :  portable

Program wrapper for the huskydoc library.
-}
module Main where

import Prelude hiding (putStrLn, readFile)

import Data.Text
import Data.Text.IO ( putStrLn, readFile )
import Text.Huskydoc ( parseAsciidoc )
import System.Environment ( getArgs )

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> putStrLn usage
    (x:_) -> do
              readFile x >>= parseAsciidoc >>= putStrLn

usage :: Text
usage = "Usage: huskydoc <INPUTFILE>\n"
