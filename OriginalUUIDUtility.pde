//使用例
void setup() {
  UUIDUtility uuid=new UUIDUtility();
  uuid.SetFromString("SampleText");
  println(uuid.toString());
  uuid.SetRandomUUID();
  println(uuid.toString());
  uuid.SetFromText("9aafaf91-7ed9-4b25-bd01-be39f6afb935");
  println(uuid.toString());
}

public final class UUIDUtility {
  //--------------------------------------------------
  //  メンバ変数定義部
  //--------------------------------------------------
  
  /** 実データ*/
  private int[] values;
  
  /** MD5の計算に使用するデータ*/
  private int[] T;


  //--------------------------------------------------
  //  コンストラクタ
  //--------------------------------------------------

  UUIDUtility() {
    //MD5の計算に使用するデータの作成
    T=new int[65];
    int T2[]={0, 
      0xD76AA478, 0xE8C7B756, 0x242070DB, 0xC1BDCEEE, 
      0xF57C0FAF, 0x4787C62A, 0xA8304613, 0xFD469501, 
      0x698098D8, 0x8B44F7AF, 0xFFFF5BB1, 0x895CD7BE, 
      0x6B901122, 0xFD987193, 0xA679438E, 0x49B40821, 

      0xF61E2562, 0xC040B340, 0x265E5A51, 0xE9B6C7AA, 
      0xD62F105D, 0x02441453, 0xD8A1E681, 0xE7D3FBC8, 
      0x21E1CDE6, 0xC33707D6, 0xF4D50D87, 0x455A14ED, 
      0xA9E3E905, 0xFCEFA3F8, 0x676F02D9, 0x8D2A4C8A, 

      0xFFFA3942, 0x8771F681, 0x6D9D6122, 0xFDE5380C, 
      0xA4BEEA44, 0x4BDECFA9, 0xF6BB4B60, 0xBEBFBC70, 
      0x289B7EC6, 0xEAA127FA, 0xD4EF3085, 0x04881D05, 
      0xD9D4D039, 0xE6DB99E5, 0x1FA27CF8, 0xC4AC5665, 

      0xF4292244, 0x432AFF97, 0xAB9423A7, 0xFC93A039, 
      0x655B59C3, 0x8F0CCC92, 0xFFEFF47D, 0x85845DD1, 
      0x6FA87E4F, 0xFE2CE6E0, 0xA3014314, 0x4E0811A1, 
      0xF7537E82, 0xBD3AF235, 0x2AD7D2BB, 0xEB86D391};
    for (int i=0; i<65; i++) {
      T2[i]=ConvertInt(T2[i]);
    }
    arrayCopy(T2, T);
  }

  //--------------------------------------------------
  //  公開メソッド
  //--------------------------------------------------

  /** UUIDの比較*/
  public boolean equals(Object obj) {
    if (obj==null)return false;
    if (obj instanceof UUIDUtility) {
      UUIDUtility rightUUID=(UUIDUtility)obj;
      if (!IsProper()||!rightUUID.IsProper()) {
        return false;
      }
      int[] rightValues=rightUUID.Get();
      for (int i=0; i<4; i++) {
        if (values[i]!=rightValues[i])return false;
      }
      return true;
    } else {
      return false;
    }
  }


  /** HashMapに対応させるため追加*/
  public int hashCode() {
    if (values==null)return 0;
    return values[0]+values[1]+values[2]+values[3];
  }

  
  /** 文字列表現に変換*/
  public String toString() {
    if (IsProper()) {
      return hex(values[0]).toLowerCase()+"-"+
      hex(values[1]).substring(0, 4).toLowerCase()+"-"+
      hex(values[1]).substring(4, 8).toLowerCase()+"-"+
      hex(values[2]).substring(0, 4).toLowerCase()+"-"+
      hex(values[2]).substring(4, 8).toLowerCase()+hex(values[3]).toLowerCase();
    } else {
      return "null";
    }
  }

  
  /** データが正しく作成されているかを確認*/
  public boolean IsProper() {
    return values!=null;
  }


  //--------------------------------------------------
  //  非公開メソッド
  //--------------------------------------------------

  /** UUIDのランダム生成(v4)*/
  private void SetRandomUUID() {
    if (!IsProper())values=new int[4];
    for (int i=0; i<4; i++) {
      values[i]=0;
      for (int j=0; j<8; j++) {
        values[i]<<=8;
        values[i]|=(int)random(0, 256);
      }
    }
    values[1]&=0xffff0fff;
    values[1]|=0x4000;
    int rand=(int)random(8, 11);
    values[2]&=0xfffffff;
    values[2]|=rand<<(4*7);
  }


  /** 文字列表現から設定*/
  private void SetFromText(String textUUID) {
    values=null;
    if (textUUID!=null&&textUUID.length()==36) {
      boolean isProper=true;
      for (int i=0; i<36; i++) {
        char c=textUUID.charAt(i);
        if (i==8||i==13||i==18||i==23) {
          if (c!='-') {
            isProper=false;
            break;
          }
        } else {
          if ((c<'0'||'9'<c)&&(c<'a'||'f'<c)&&(c<'A'||'F'<c)) {
            isProper=false;
            break;
          }
        }
      }
      if (isProper) {
        if (values==null)values=new int[4];
        values[0]=unhex(textUUID.substring(0, 8));
        values[1]=unhex(textUUID.substring(9, 13)+textUUID.substring(14, 18));
        values[2]=unhex(textUUID.substring(19, 23)+textUUID.substring(24, 28));
        values[3]=unhex(textUUID.substring(28, 36));
      }
      return;
    }
  }


  /** バイトデータから設定*/
  private void SetFromString(String str) {
    int[] bytes=new int[str.length()];
    for (int i=0, end=str.length(); i<end; i++) {
      for (int j=0; j<128; j++) {
        //型変換が正しくできないのでアスキー神殿一覧から変換。見ての通りTabを含んだ文字列は通常とは違う値になる。非バイナリデータ推奨
        String ascii = "\t\t\t\t\t\t\t\t\t\t\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]~_'abcdefghijklmnopqrstuvwxyz{|}~\t";
        if (ascii.charAt(j)==str.charAt(i)) {
          bytes[i]=j;
          break;
        }
      }
    }
    SetFromBytesByInts(bytes);
  }

  private void SetFromBytesByInts(int[] bytes) {
    if (bytes!=null) {
      //Step1
      int byteLen=bytes.length;
      int newByteLength=byteLen-byteLen%64+64;
      if (56<=byteLen%64)newByteLength+=64;

      int[] newBytes=new int[newByteLength];
      for (int i=0; i<byteLen; i++) {
        newBytes[i]=bytes[i];
      }

      //Step2
      for (int i=0, temp=byteLen; i<8; i++) {
        newBytes[newByteLength-8+i]=temp&0x000000FF;
        temp>>=8;
      }

      //Step3
      int A = 1732584193;
      int B = -271733879;
      int C = -1732584194;
      int D = 271733878;

      //Step4
      int[] X=new int[16];
      int[] abcd=new int[4];
      abcd[0]=A;
      abcd[1]=B;
      abcd[2]=C;
      abcd[3]=D;

      for (int i=0; i<newByteLength; i++) {
        int it=int(newBytes[i]);
        X[i%16]=it;
        if (i%16==15) {
          int[] s1={7, 12, 17, 22};
          int[] s2={5, 9, 14, 20};
          int[] s3={4, 11, 16, 23};
          int[] s4={6, 10, 15, 21};
          for (int j=0; j<64; j++) {
            int aNum=(64-j)%4;
            int bNum=(65-j)%4;
            int cNum=(66-j)%4;
            int dNum=(67-j)%4;
            if (j<16) {
              abcd[aNum] = ConvertInt(abcd[aNum]+MD5F(abcd[bNum], abcd[cNum], abcd[dNum]) + X[j%16] + T[j+1]); 
              abcd[aNum] = ROTATE_LEFT(abcd[aNum], s1[aNum]); 
              abcd[aNum] = ConvertInt(abcd[aNum]+abcd[bNum]);
            } else if (j<32) {
              abcd[aNum] = ConvertInt(abcd[aNum]+MD5G(abcd[bNum], abcd[cNum], abcd[dNum]) + X[j%16] + T[j+1]); 
              abcd[aNum] = ROTATE_LEFT(abcd[aNum], s2[aNum]); 
              abcd[aNum] = ConvertInt(abcd[aNum]+abcd[bNum]);
            } else if (j<48) {
              abcd[aNum] = ConvertInt(abcd[aNum]+MD5H(abcd[bNum], abcd[cNum], abcd[dNum]) + X[j%16] + T[j+1]); 
              abcd[aNum] = ROTATE_LEFT(abcd[aNum], s3[aNum]); 
              abcd[aNum] = ConvertInt(abcd[aNum]+abcd[bNum]);
            } else {
              abcd[aNum] = ConvertInt(abcd[aNum]+MD5I(abcd[bNum], abcd[cNum], abcd[dNum]) + X[j%16] + T[j+1]); 
              abcd[aNum] = ROTATE_LEFT(abcd[aNum], s4[aNum]); 
              abcd[aNum] = ConvertInt(abcd[aNum]+abcd[bNum]);
            }
          }
          abcd[0]+=A;
          abcd[1]+=B;
          abcd[2]+=C;
          abcd[3]+=D;
        }
      }

      for (int i=0; i<4; i++) {
        int temp=abcd[i];
        int ret=0;
        for (int j=0; j<4; j++) {
          ret|=((temp>>(j*8))&0xff)<<((4-j)*8);
        }
        abcd[i]=ret;
      }

      values=new int[4];
      for (int i=0; i<4; i++) {
        values[i]=abcd[i];
      }
    } else {
      values=null;
    }
  }


  /** 実データで設定*/
  private void Set(int[] values) {
    if (values!=null&&values.length!=4) {
      if (this.values==null)this.values=new int[4];
      for (int i=0; i<4; i++) {
        this.values[i]=values[i];
      }
    }
  }

  
  /** MD5アルゴリズムの計算に使用*/
  private int MD5F(int x, int y, int z) {
    return ((x) & (y)) | ((~x) & (z));
  }

  private int MD5G(int x, int y, int z) {
    return ((x) & (z)) | ((y) & (~z));
  }

  private int MD5H(int x, int y, int z) {
    return (x) ^ (y) ^ (z);
  }

  private int MD5I(int x, int y, int z) {
    return (y) ^ ((x) | (~z));
  }

  private int ROTATE_LEFT(int x, int n) {
    int ret=(((x) << (n)) | ((x) >> (32-(n))));
    return ret&0xffffffff;
  }
  
  /** JavaScriptとデータの扱いが違うので互換性を持つように変換*/
  private int ConvertInt(int value) {
    return value&0xffffffff;
  }


  //--------------------------------------------------
  //  getter/setter
  //--------------------------------------------------

  /** 実データの取得*/
  public int[] Get() {
    int[] copy=new int[4];
    if (IsProper()) {
      for (int i=0; i<4; i++) {
        copy[i]=values[i];
      }
    }
    return copy;
  }
}