These files mock TPM2 data returned by `tpm2_getcap -c properties-fixed`,
however they are not actual dumps; they are derived from publicly-available
sources

```
tpm2_getcap_-c_properties-fixed/
├── infineon-slb9670.yaml         # https://github.com/tpm2-software/tpm2-tools/issues/407#issuecomment-323237350
├── nationz-z32h320tc.yaml        # https://github.com/tpm2-software/tpm2-tools/issues/335#issuecomment-339525716
├── nuvoton-ncpt6xx-fbfc85e.yaml  # https://www.commoncriteriaportal.org/files/epfiles/anssi-cible2017_55en.pdf
└── nuvoton-ncpt7xx-lag019.yaml   # https://www.commoncriteriaportal.org/files/epfiles/anssi-cible-cc-2017_75en.pdf
```
