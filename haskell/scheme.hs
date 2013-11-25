#!/usr/bin/env runhaskell
module Main where
import System.Environment
import Data.Maybe
import Text.ParserCombinators.Parsec hiding (spaces)
import Control.Monad
import qualified Data.Map as Map
import Numeric (readFloat)
import Data.Ratio (Rational,(%))

main = do
  exprs <- readFile "test.scm"
  sequence_ $ map (putStrLn . readExpr) $ lines exprs
  

data LispVal = Atom String
             | List [LispVal]
             | DottedList [LispVal] LispVal
             | Integer Integer
             | Float Float
             | Rational Rational 
             | Bool Bool
             | String String
             | Char Char
             deriving (Show,Eq)


listExpr = liftM List $ sepBy expr spaces


dottedListExpr = do
  h <- endBy expr spaces
  t <- char '.' >> spaces >> expr
  return $ DottedList h t


stringExpr = do
  char '"'
  s <- strRemain
  char '"'
  return $ String s


strRemain :: Parser String
strRemain = (many $ noneOf "\"\\") >>= \s ->
  (char '\\' >> satisfy isEscapeChar >>= \q->
      strRemain >>= \rs ->
          return $ s ++ (getEscapeChar q):rs
  ) <|> return s

isEscapeChar :: Char -> Bool
isEscapeChar = flip Map.member $ escapeCharMap

getEscapeChar :: Char -> Char
getEscapeChar c = fromJust $ Map.lookup c escapeCharMap 

atomExpr = do
  first <- letter <|> symbol
  rest <- many $ letter <|> symbol <|> digit
  let atom = first:rest
  return $ Atom atom

boolExpr = oneOf "tf" >>= return . Bool . (== 't')

charExpr = do
  char '\\'
  n <- (many1 letter) <|> (anyToken>>=return.(: []))
  return $ Char $ charFromName n

radixNumExpr = hexIntExpr <|>
               binIntExpr <|>
               octIntExpr <|>
               exactNumExpr <|>
               (oneOf "id">>numberExpr)

numberExpr = many digit >>= \i->
                if null i then floatPart i False
                else floatPart i False <|> denominatorPart i <|> integerOnly i

integerOnly :: String -> Parser LispVal
integerOnly i = (powerPart >>= \p -> return . Integer . (* p) $ read i)  <|>
                (return . Integer $ read  i)

floatPart :: String -> Bool -> Parser LispVal
floatPart i exact = char '.' >> 
    many digit >>= \a -> 
      if null (i++a) then fail "Single '.' cant be treated as float!"
      else
        let n = '0':i ++ '.':a ++ "0" in 
        ((char 'e' >> many1 digit) <|> return "0") >>= \p ->
          if exact then
              return . Rational . fst . head $ readFloat (n ++ "e" ++p)
          else return . Float $ read  (n ++ "e" ++p)

powerPart :: Parser Integer
powerPart = char 'e' >> many1 digit >>= return . (10^) . read
  
denominatorPart :: String -> Parser LispVal
denominatorPart numerator = char '/' >> many1 digit >>= 
                    \denominator -> 
                        if denominator == "0" then fail $ "Division by zero:"++numerator++"/0"
                        else
                          let r = read $ numerator ++ "%" ++ denominator in 
                          (powerPart >>= return . Rational . (* r) . toRational) <|>
                          (return $ Rational r)

exactNumExpr = char 'e' >> many digit >>= \i->
                if null i then floatPart i True
                else floatPart i True <|> denominatorPart i <|> integerOnly i

hexIntExpr = char 'x' >> liftM (Integer . read . ("0x" ++)) (many1 hexDigit)
binIntExpr = char 'b' >> liftM (Integer . readBinary) (many1 (oneOf "01"))
octIntExpr = char 'o' >> liftM (Integer . read . ("0o" ++)) (many1 octDigit)

sharpTokenExpr = char '#' >> (boolExpr <|> charExpr <|> radixNumExpr)

expr :: Parser LispVal
expr = stringExpr <|> sharpTokenExpr <|> atomExpr <|> numberExpr

spaces :: Parser ()
spaces = skipMany1 space

symbol :: Parser Char
symbol = oneOf "!#$%&|*+-/:<=>?@^_~"

readExpr :: String -> String
readExpr input = case parse expr "lisp" input of
                    Left err -> "No match: " ++ show err
                    Right val -> "Found value: " ++ show val


charNameMap = Map.fromList [
  ("newline",'\n'),
  ("tab",'\t'),
  ("space",' ')]

charFromName :: String -> Char
charFromName [a] = a
charFromName name = case Map.lookup name charNameMap of
                          Just c -> c
                          Nothing -> error $ "Bad char name:" ++ show name

escapeCharMap = Map.fromList [
  ('\\','\\'),
  ('"','"'),
  ('n','\n'),
  ('t','\t'),
  ('r','\r')]

{-
unescape :: String -> String
unescape s= foldr (\(k,v) s->replace k v s) s escapeList
-}

replace :: String -> String -> String -> String
replace search new haystack | n > (length haystack) = haystack
                            | otherwise =  if take n haystack  == search then
                                             new ++ replace search new (drop n haystack)
                                           else
                                             (head haystack):(replace search new (tail haystack))
                            where n = length search

readBinary :: String -> Integer
readBinary =  snd . foldr (\t (r,a)->(r+1,(if t then 2^r else 0)+a)) (0,0) . map (== '1')

