use chain_impl_mockchain::certificate::Certificate;
use jcli_app::transaction::{common, Error};
use jormungandr_utils::certificate;
use structopt::StructOpt;

#[derive(StructOpt)]
#[structopt(rename_all = "kebab-case")]
pub struct AddCertificate {
    #[structopt(flatten)]
    pub common: common::CommonTransaction,

    /// the value
    #[structopt(
        name = "VALUE",
        parse(try_from_str = "certificate::deserialize_from_bech32")
    )]
    pub certificate: Certificate,
}

impl AddCertificate {
    pub fn exec(self) -> Result<(), Error> {
        let mut transaction = self.common.load()?;
        transaction.set_extra(self.certificate)?;
        self.common.store(&transaction)
    }
}
