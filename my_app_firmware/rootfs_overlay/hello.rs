use std::fs::File;

fn main() -> () {
    match hello("sadsad".as_str()) {
	Ok(variable) =>
	{
	    dbg!(variable);
	}
	_ =>
	{
	    dbg!("error");
	}
    }
}




fn hello<'a> (buffer: &'a str) -> Result<String , u8> {
    Ok(File::write(buffer)?)
}
