//
//  PlayingCard.m
//  Matchismo
//
//  Created by Boris Talesnik on 07/03/2016.
//
//

#import "PlayingCard.h"

@implementation PlayingCard

- (NSString *)contents
{
  return [[PlayingCard rankStrings][self.rank] stringByAppendingString:self.suit];
}

@synthesize suit = _suit;

- (NSString *)suit
{
  return _suit ? _suit : @"?";
}

- (void)setSuit:(NSString *)suit
{
  if([[PlayingCard validSuits] containsObject:suit])
  {
    _suit = suit;
  }
}

- (int)match:(NSArray *)otherCards
{
  int score = 0;

  
  for (PlayingCard * otherCard in otherCards) {
    if (otherCard.rank == self.rank) {
      score = 4;
    }else if ([otherCard.suit isEqualToString:self.suit]){
      score = 1;
    }
  }
  
  if ([otherCards count] > 1) {
    score += [[otherCards firstObject ] match:[otherCards subarrayWithRange:NSMakeRange(1, [otherCards count] - 1)]];
  }
  
  return score;
}

+ (NSArray *)validSuits
{
  return @[@"♠️", @"♣️", @"♥️", @"♦️"];
}

+ (NSUInteger)maxRank
{
  return [[PlayingCard rankStrings] count] - 1;
}

+ (NSArray *)rankStrings
{
  return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K"];
}

@end
