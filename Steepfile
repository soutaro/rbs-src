D = Steep::Diagnostic

target :lib do
  signature "sig"

  check "lib"                       # Directory name

  configure_code_diagnostics(D::Ruby.default)      # `default` diagnostics setting (applies by default)

  # configure_code_diagnostics(D::Ruby.strict)       # `strict` diagnostics setting
  # configure_code_diagnostics(D::Ruby.lenient)      # `lenient` diagnostics setting
  # configure_code_diagnostics(D::Ruby.silent)       # `silent` diagnostics setting
  # configure_code_diagnostics do |hash|             # You can setup everything yourself
  #   hash[D::Ruby::NoMethod] = :information
  # end

  # `rbs-src setup -o` generates `rbs_src.dep` file
  if (dep_path = Pathname("rbs_src.dep")).file?
    # Stop loading libraries through rbs-collection
    disable_collection()

    signature "sig/rbs-src/*/*.rbs"
    signature "sig/rbs-src/*/[^_]*/**/*.rbs"

    dep_path.readlines().each {|lib| library(lib.chomp) }
  end
end
