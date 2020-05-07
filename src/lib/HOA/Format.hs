-----------------------------------------------------------------------------
-- |
-- Module      :  HOA.Format
-- Maintainer  :  Philippe Heim (Heim@ProjectJARVIS.de)
--
-- The internal representation of an HOA
--
-----------------------------------------------------------------------------
{-# LANGUAGE LambdaCase, FlexibleInstances, MultiParamTypeClasses,
  DeriveGeneric, TemplateHaskell, RecordWildCards #-}

-----------------------------------------------------------------------------
module HOA.Format where

-----------------------------------------------------------------------------
import Data.Set as Set (Set)
import Finite.TH (baseInstance, newInstance)
import GHC.Generics (Generic)
import Sat.Finite (Formula)
import Finite

-----------------------------------------------------------------------------
-- | The type of a state, generated using the Finite library
newInstance "State"

-----------------------------------------------------------------------------
-- | The type of an atomic proposition, generated using the Finite library
newInstance "AP"

-----------------------------------------------------------------------------
-- | The type of an acceptance set, generated using the Finite library
newInstance "AcceptanceSet"

type AcceptanceSets = Set AcceptanceSet

-----------------------------------------------------------------------------
-- | The different properties of a HOA
-- Remark: The properties do not contain implicit-labels, explicit-labels,
-- as in the internal format all labels are explicit 
-- (implicit ones have to be parsed before)
data HOAProperty
  = ONLY_STATE_LABELS
  | ONLY_TRANS_LABELS
  | PURE_STATE_ACCEPTANCE
  | PURE_TRANS_ACCEPTRACE
  | UNIV_BRANCHING
  | NO_UNIV_BRANCHING
  | DETERMINISTIC
  | COMPLETE
  | UNAMBIGOUS
  | STUTTER_INVARIANT
  | WEAK
  | VERY_WEAK
  | INHERENTLY_WEAK
  | TERMINAL
  | TIGHT
  | COLORED
  deriving (Eq, Ord, Show)

-----------------------------------------------------------------------------
-- | All possible HOA acceptance names with the respective parameters
data HOAAcceptanceName
  = Buchi
  | CoBuchi
  | GeneralizedBuchi Int
  | GeneralizedCoBuchi Int
  | Streett Int
  | Rabin Int
  | GeneralizedRabin Int Int Int
  | ParityMinOdd Int
  | ParityMaxOdd Int
  | ParityMinEven Int
  | ParityMaxEven Int
  | All
  | None
  | Unknown
  deriving (Show)
-----------------------------------------------------------------------------
-- | The definition of an acceptance condition, which is a propositional formula
-- over acceptance sets that are visited finitely of infinitely often
data AcceptanceType
  = Fin Bool AcceptanceSet
  | Inf Bool AcceptanceSet
  deriving (Eq, Ord, Show, Generic)

type AcceptanceCondition = Formula AcceptanceType

instance Finite HOA AcceptanceType

instance Finite HOA Bool 

-----------------------------------------------------------------------------
-- | The definition of a label, which is a propositional formula over 
-- atomic propositions
type Label = Formula AP

-----------------------------------------------------------------------------
-- | The internal presentation of an HOA, note that alias and implicit labels
-- are not represented anymore
data HOA =
  HOA
      -- | Number of states (set can be computed via the type)
    { size :: Int
      -- | Set of initial states
    , initialStates :: Set State
      -- | Number of atomic propositions (set can be computed via the type)
    , atomicPropositions :: Int
      -- | Name of the atomic proposition
    , atomicPropositionName :: AP -> String
      -- | Controlable APs, typcally outputs (Syntcomp Extension)
    , controlableAPs :: Set AP
      -- | Acceptance name 
    , acceptanceName :: HOAAcceptanceName
      -- | Number of acceptance sets (the sets can be computed via the type)
    , acceptanceSets :: Int
      -- | Acceptance condition
    , acceptance :: AcceptanceCondition
      -- | Tool name (might be empty)
    , tool :: (String, Maybe String)
      -- | Automaton name
    , name :: String
      -- | Properties
    , properties :: Set HOAProperty
      -- | Set of edges for each state, an edge consists of target state
      -- a optional label and an optional set of acceptance sets
    , edges :: State -> Set (State, Maybe Label, Maybe AcceptanceSets)
      -- | For each state a possible label
    , stateLabel :: State -> Maybe Label
      -- | For each state a possible set of acceptance sets
    , stateAcceptance :: State -> Maybe AcceptanceSets
      -- | Name of a state (might be empty)
    , stateName :: State -> String
    }

-----------------------------------------------------------------------------
-- | The instantiation of the State type
baseInstance [t|HOA|] [|size|] "State"

-----------------------------------------------------------------------------
-- | The instantiation of the atomic proposition type
baseInstance [t|HOA|] [|atomicPropositions|] "AP"

-----------------------------------------------------------------------------
-- | The instantiation of the acceptance set type
baseInstance [t|HOA|] [|acceptanceSets|] "AcceptanceSet"