module Control.Monad.Bayes.Examples.LinRegr

import Data.Maybe
import Data.List
import Control.Monad.Bayes.Interface
import Control.Monad.Bayes.Sampler
import Statistics.Distribution.Normal
import Numeric.Log

record LinRegrParams where
  constructor MkLinRegrParams
  m : Double
  c : Double
  σ : Double

linRegr_prior : MonadSample m => Maybe Double -> Maybe Double -> Maybe Double -> m LinRegrParams
linRegr_prior m0 c0 s0 = do
  m <- normal 0 3
  c <- normal 0 5
  s <- uniform 1 3
  let m' = fromMaybe m m0
      c' = fromMaybe c c0
      s' = fromMaybe s s0
  pure (MkLinRegrParams m' c' s')

linRegr_sim : MonadSample m => Maybe Double -> Maybe Double -> Maybe Double -> List Double -> m (List Double)
linRegr_sim m0 c0 s0 xs  = do
  MkLinRegrParams m c s <- linRegr_prior m0 c0 s0
  foldlM (\ys, x => do y <- normal (m * x + c) s
                       pure (y::ys)) [] xs

linRegr_inf : MonadInfer m => Maybe Double -> Maybe Double -> Maybe Double -> List (Double, Double) -> m LinRegrParams
linRegr_inf m0 c0 s0 xys  = do
  MkLinRegrParams mean c s <- linRegr_prior m0 c0 s0
  _ <- sequence (map (\(x, y_obs) => score (Exp $ normal_pdf (mean * x + c) s y_obs)) xys)
  pure (MkLinRegrParams mean c s)

simLinRegr : Nat -> IO (List Double)
simLinRegr n_datapoints = do
  sampleIO $ (linRegr_sim (Just 3) (Just 0) (Just 1) (map cast [0 ..  n_datapoints]))

