# A strucured fact that return some facts about a TPM 2.0 TPM
Facter.add('tpm') do
  # This line is intentionally commented out.
  # With TPM 2.0 and TCTI, the TPM device may not be local. This makes the
  # :has_tpm detection strategy used for TPM 1 unreliable.
  ### confine :has_tpm => true

  # Instead of confining on :has_tpm, we confine _against_ being a TPM 1.
  #
  # The fact will still be nil if the tpm2-tools aren't available or aren't
  # configured to comminucate with the TPM
  confine :tpm_version do |value|
    value != 'tpm1'
  end
  setcode do
    require 'facter/tpm2/util'
    Facter::TPM2::Util.new.build_structured_fact
  end
end

