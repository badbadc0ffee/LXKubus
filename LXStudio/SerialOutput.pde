import processing.serial.*;

public static class SerialOutput extends LXOutput {
  private Serial port;
  public SerialOutput(LX lx, Serial port) {
    super(lx);
    this.port = port;
  }
  public void onSend(int[] colors) {
    int len = colors.length-1;
    port.write("Ada");
    port.write((byte)(len/0x100));
    port.write((byte)(len%0x100));
    port.write((byte)(len/0x100 ^ len%0x100 ^ 0x55));
    int i=0;
    for (int c : colors) {
      byte r = (byte)((c >> 16) & 0xff);
      byte g = (byte)((c >> 8) & 0xff);
      byte b = (byte)(c & 0xff);
      port.write(r);
      port.write(g);
      port.write(b);
    }
    try
    {    
      Thread.sleep(100);
    }
    catch(Exception e) {
    }
  }
}
