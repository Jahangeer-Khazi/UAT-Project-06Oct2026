/**
 *  @author: Juan Trujillo (westbrook)
 *  @date: 2021-10-05
 *  @description:
 *      generate unique one time password value
 *
 *  Version History :
 *  2021-10-05 - JT
 *  2021-10-06 - HP
 *
 *
 */

public with sharing class RandomNumGenerator {
    // Generates random six-digit number to be used for an OTP
    @InvocableMethod(label='Login flow Random Number' description='Create random six digit number for a login flow' Category ='Flow')
    public static List<Integer> randomNumber(List<ID> ids) {
    Integer randomNumber = Integer.valueof((Math.random() * (900000) + 100000 ));
    return new List<Integer> {randomNumber};
  }
}