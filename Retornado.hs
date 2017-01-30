{-# LANGUAGE OverloadedStrings #-}
module Retornado where

import Visie
import Visie.Data
import Visie.ToTimeSeries
import Visie.Index ( IndexType(..) )
import Paths_retornado (getDataFileName)
import Data.DateTime (getCurrentTime)
import Data.Time.Clock (NominalDiffTime)

import qualified Data.Aeson as A
import qualified Data.HashMap.Strict as H
import qualified Data.Text as T
import qualified Data.Text.Lazy as TextLazy
import qualified Data.Text.Lazy.Encoding as TextLazy
import qualified Data.Vector as V
import Data.Scientific (fromFloatDigits)
import Data.Time.Format (formatTime, defaultTimeLocale)
import Data.List (sortOn)
import Data.Time.Clock hiding (getCurrentTime)

dateFormat :: UTCTime -> T.Text
dateFormat = T.pack . formatTime defaultTimeLocale "%D"

toText :: [Timestamped TextFloat] -> T.Text
toText =
  let single (Timestamped (TextFloat te fl) ti) = A.Object (H.fromList [("key", A.String te), ("value", (A.Number . fromFloatDigits) fl), ("date", (A.String . dateFormat) ti)])
  in TextLazy.toStrict . TextLazy.decodeUtf8 . A.encode . A.toJSON . A.Array . V.fromList . map single . sortOn getTime

oneDay = 60 * 60 * 24 :: NominalDiffTime

transform today days = toText . convertFill today (oneDay * fromIntegral days) . map toTimestampedTextFloat

options = defaultOptions { additionalScripts = [ResourceDesc { fetch = "data/tornado.js", serve = "tornado.js" }], d3Version = Version3, indexType = ChartDiv }

retornado days d = do
  today <- getCurrentTime
  customVisie options getDataFileName (transform today days) d
