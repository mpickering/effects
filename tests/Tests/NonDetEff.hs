{-# LANGUAGE FlexibleContexts, TypeOperators #-}
module Tests.NonDetEff where

import Control.Applicative
import Control.Monad
import Control.Monad.Effect
import Control.Monad.Effect.NonDetEff

ifte :: (NonDetEff :< e)
     => Eff e a
     -> (a -> Eff e b)
     -> Eff e b
     -> Eff e b
ifte t th el = msplit t >>= maybe el (\(a,m) -> th a <|> (m >>= th))

generatePrimes :: (NonDetEff :< e) => [Int] -> Eff e Int
generatePrimes xs = do
  n <- gen
  ifte (do d <- gen
           guard $ d < n && n `mod` d == 0)
       (const mzero)
       (return n)
  where gen = msum (fmap return xs)

testIfte :: [Int] -> [Int]
testIfte = run . makeChoiceA . generatePrimes
