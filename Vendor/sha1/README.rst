NAME
     SHA1Init, SHA1Update, SHA1Final, SHA1Transform

SYNOPSIS
    #include <sys/types.h>
    
    #include <sha1.h>

    void SHA1Transform(
        uint32_t state[5],
        const unsigned char buffer[64]);

    void SHA1Init(
        SHA1_CTX * context);

    void SHA1Update(
        SHA1_CTX * context,
        const unsigned char *data,
        uint32_t len);

    void SHA1Final(
        unsigned char digest[20],
        SHA1_CTX * context);

DESCRIPTION
     The SHA1 functions implement the NIST Secure Hash Algorithm (SHA-1), FIPS
     PUB 180-1.  SHA-1 is used to generate a condensed representation of a
     message called a message digest.  The algorithm takes a message less than
     2^64 bits as input and produces a 160-bit digest suitable for use as a
     digital signature.

     The SHA1Init() function initializes a SHA1_CTX context for use with
     SHA1Update(), and SHA1Final().  The SHA1Update() function adds data of
     length len to the SHA1_CTX specified by context.  SHA1Final() is called
     when all data has been added via SHA1Update() and stores a message digest
     in the digest parameter.  When a null pointer is passed to SHA1Final() as
     first argument only the final padding will be applied and the current
     context can still be used with SHA1Update().

     The SHA1Transform() function is used by SHA1Update() to hash 512-bit
     blocks and forms the core of the algorithm.  Most programs should use the
     interface provided by SHA1Init(), SHA1Update() and SHA1Final() instead of
     calling SHA1Transform() directly.

EXAMPLES
     The follow code fragment will calculate the digest for the string "abc"
     which is ``0xa9993e36476816aba3e25717850c26c9cd0d89d''.

           SHA1_CTX sha;
           uint8_t results[20];
           char *buf;
           int n;

           buf = "abc";
           n = strlen(buf);
           SHA1Init(&sha);
           SHA1Update(&sha, (uint8_t *)buf, n);
           SHA1Final(results, &sha);

           /* Print the digest as one long hex value */
           printf("0x");
           for (n = 0; n < 20; n++)
                   printf("%02x", results[n]);
           putchar('\n');

     Alternately, the helper functions could be used in the following way:

           SHA1_CTX sha;
           uint8_t output[41];
           char *buf = "abc";

           printf("0x%s", SHA1Data(buf, strlen(buf), output));

AUTHORS
     This implementation of SHA-1 was written by Steve Reid.

BUGS
     This implementation of SHA-1 has not been validated by NIST and as such
     is not in official compliance with the standard.

     If a message digest is to be copied to a multi-byte type (ie: an array of
     five 32-bit integers) it will be necessary to perform byte swapping on
     little endian machines such as the i386, alpha, and VAX.
