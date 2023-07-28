D = Steep::Diagnostic

target :lib do
  signature "sig"
  signature "sig/rbs-src/*/**/*.rbs"

  check "lib"                       # Directory name


  configure_code_diagnostics(D::Ruby.default)      # `default` diagnostics setting (applies by default)
  # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
  # configure_code_diagnostics(D::Ruby.lenient)      # `lenient` diagnostics setting
  # configure_code_diagnostics(D::Ruby.silent)       # `silent` diagnostics setting
  # configure_code_diagnostics do |hash|             # You can setup everything yourself
  #   hash[D::Ruby::NoMethod] = :information
  # end


  library "abbrev"
  library "date"
  library "dbm"
  library "json"
  library "logger"
  library "minitest"
  library "monitor"
  library "mutex_m"
  library "optparse"
  library "pathname"
  library "pstore"
  library "rbs"
  library "rdoc"
  library "securerandom"
  library "singleton"
  library "time"
  library "tsort"
  library "yaml"

  disable_collection
end
