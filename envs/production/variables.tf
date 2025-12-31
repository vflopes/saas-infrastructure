variable "google_site_verification_value" {
  description = "The value of TXT used for Google site verification."
  type        = string
  default     = "google-site-verification=b_miX_UWS8tQhLuNSdPn41EsCp7kTY2pvwDFxGVqZmg"
}

variable "gmail_dkim_value" {
  description = "The value of the DKIM CNAME record for Gmail."
  type        = string
  default     = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzFp+CJbawvhn9aFhvFDjxjhdJ9WfJNjuou28z3CBPmkpWsGjyWUlbiIPaLU8cOO3VMJreul4H4abdIbd4EMVxapIUllwoFgDR9Cya8ai7flfUVn6+suBMzSBVT82cy+UK21gZE+P2JRbW/CY/1rNSUz9eeB6wO6lDjKyTJuwch5xtCIQHwntIoPY5gws9Ttc1\"\"ku8bNcXqU5J9amW94aDkHIJqk3b7SBB2OJk/K8XzNAotGik37/XWuOW/v/HfUKrnzzY34uXtxwqKmkL5AbwJi8wSokIxvl25PR0BzWd1T5rbckNyyq+Er553rPgOWk6xIJZbICXkoAts3e2HzPaYQIDAQAB"
}
