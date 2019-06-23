/*
SHA1 tests by Philip Woolford <woolford.philip@gmail.com>
100% Public Domain
 */

#include "sha1.h"
#include "CUnit/Basic.h"
#include "stdio.h"
#include "string.h"

#define SUCCESS 0

/* The suite initialization function.
 * Returns zero on success, non-zero otherwise.
 */
int init_suite(
    void
)
{
  return 0;
}

/* The suite cleanup function.
 * Returns zero on success, non-zero otherwise.
 */
int clean_suite(
    void
)
{
  return 0;
}

/* Test Vector 1 */
void testvec1(
    void
)
{
  char const string[] = "abc";
  char const expect[] = "a9993e364706816aba3e25717850c26c9cd0d89d";
  char result[21];
  char hexresult[41];
  size_t offset;

  /* calculate hash */
  SHA1( result, string, strlen(string) );

  /* format the hash for comparison */
  for( offset = 0; offset < 20; offset++) {
    sprintf( ( hexresult + (2*offset)), "%02x", result[offset]&0xff);
  }

  CU_ASSERT( strncmp(hexresult, expect, 40) == SUCCESS );
}

/* Test Vector 2 */
void testvec2(
    void
)
{
  char const string[] = "";
  char const expect[] = "da39a3ee5e6b4b0d3255bfef95601890afd80709";
  char result[21];
  char hexresult[41];
  size_t offset;

  /* calculate hash */
  SHA1( result, string, strlen(string) );

  /*format the hash for comparison */
  for( offset = 0; offset < 20; offset++) {
    sprintf( ( hexresult + (2*offset)), "%02x", result[offset]&0xff);
  }

  CU_ASSERT( strncmp(hexresult, expect, 40) == SUCCESS );
}

/* Test Vector 3 */
void testvec3(
    void
)
{
  char const string[] = "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq";
  char const expect[] = "84983e441c3bd26ebaae4aa1f95129e5e54670f1";
  char result[21];
  char hexresult[41];
  size_t offset;

  /* calculate hash */
  SHA1( result, string, strlen(string) );

  /* format the hash for comparison */
  for( offset = 0; offset < 20; offset++) {
    sprintf( ( hexresult + (2*offset)), "%02x", result[offset]&0xff);
  }

  CU_ASSERT( strncmp(hexresult, expect, 40) == SUCCESS );
}

/* Test Vector 4 */
void testvec4(
    void
)
{
  char const string1[] = "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghij";
  char const string2[] = "klmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu";
  char const expect[] = "a49b2446a02c645bf419f995b67091253a04a259";
  unsigned char result[21];
  char hexresult[41];
  size_t offset;
  SHA1_CTX ctx;

  /* calculate hash */
  SHA1Init(&ctx);
  SHA1Update( &ctx, (unsigned char const *)string1, strlen(string1) );
  SHA1Update( &ctx, (unsigned char const *)string2, strlen(string2) );
  SHA1Final(result, &ctx);

  /* format the hash for comparison */
  for( offset = 0; offset < 20; offset++) {
    sprintf( ( hexresult + (2*offset)), "%02x", result[offset]&0xff);
  }

  CU_ASSERT( strncmp(hexresult, expect, 40) == SUCCESS );
}

/* Test Vector 5 */
void testvec5(
    void
)
{
  char string[1000001];
  char const expect[] = "34aa973cd4c4daa4f61eeb2bdbad27316534016f";
  char result[21];
  char hexresult[41];
  int iterator;
  size_t offset;

  /* generate string */
  for( iterator = 0; iterator < 1000000; iterator++) {
    string[iterator] = 'a';
  }
  string[1000000] = '\0';

  /* calculate hash */
  SHA1( result, string, strlen(string) );

  /* format the hash for comparison */
  for( offset = 0; offset < 20; offset++) {
    sprintf( ( hexresult + (2*offset)), "%02x", result[offset]&0xff);
  }

  CU_ASSERT( strncmp(hexresult, expect, 40) == SUCCESS );
}

/* Test Vector 6 */
void testvec6(
    void
)
{
  char const string[] = "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmno";
  char const expect[] = "7789f0c9ef7bfc40d93311143dfbe69e2017f592";
  unsigned char result[21];
  char hexresult[41];
  int iterator;
  size_t offset;
  SHA1_CTX ctx;

  /* calculate hash */
  SHA1Init(&ctx);
  for ( iterator = 0; iterator < 16777216; iterator++) {
    SHA1Update( &ctx, (unsigned char const *)string, strlen(string) );
  }
  SHA1Final(result, &ctx);

  /* format the hash for comparison */
  for( offset = 0; offset < 20; offset++) {
    sprintf( ( hexresult + (2*offset)), "%02x", result[offset]&0xff);
  }

  CU_ASSERT( strncmp(hexresult, expect, 40) == SUCCESS );
}

int main(
    void
)
{
  CU_pSuite pSuite = NULL;

  /* initialize the CUnit test registry */
  if (CUE_SUCCESS != CU_initialize_registry())
    return CU_get_error();

  /* add a suite to the registry */
  pSuite = CU_add_suite("http://www.di-mgt.com.au/sha_testvectors.html", init_suite, clean_suite);
  if (NULL == pSuite) {
    CU_cleanup_registry();
    return CU_get_error();
  }

  /* add the tests to the suite */
  if ((NULL == CU_add_test(pSuite, "Test of Test Vector 1", testvec1)) ||
     (NULL == CU_add_test(pSuite, "Test of Test Vector 2", testvec2)) ||
     (NULL == CU_add_test(pSuite, "Test of Test Vector 3", testvec3)) ||
     (NULL == CU_add_test(pSuite, "Test of Test Vector 4", testvec4)) ||
     (NULL == CU_add_test(pSuite, "Test of Test Vector 5", testvec5)) ||
     (NULL == CU_add_test(pSuite, "Test of Test Vector 6", testvec6)))
  {
    CU_cleanup_registry();
    return CU_get_error();
  }

  /* Run all tests using the CUnit Basic interface */
  CU_basic_set_mode(CU_BRM_VERBOSE);
  CU_basic_run_tests();
  CU_cleanup_registry();
  return CU_get_error();
}
