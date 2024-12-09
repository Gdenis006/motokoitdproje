import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
actor KonyaUlasim {
    // Durak bilgileri türü
    type Durak = {
        id : Nat;
        ad : Text;
        semtAdi : Text;
        koordinatX : Float;
        koordinatY : Float;
    };

    // Otobüs hat bilgileri türü
    type OtobusHatti = {
        id : Nat;
        hatAdi : Text;
        baslangicDuragi : Text;
        bitisDuragi : Text;
        guzergah : [Text];
    };

    // Otobüs bilgileri türü
    type Otobus = {
        id : Nat;
        hatId : Nat;
        plaka : Text;
        kapasite : Nat;
        mevcutYolcuSayisi : Nat;
        aktifDurak : Text;
    };

    // Konya'nın önemli otobüs durakları
    let konyaDuraklar : [Durak] = [
        { 
            id = 1; 
            ad = "Meram Terminal"; 
            semtAdi = "Meram";
            koordinatX = 37.8672; 
            koordinatY = 32.4987 
        },
        { 
            id = 2; 
            ad = "Selçuklu Transfer Merkezi"; 
            semtAdi = "Selçuklu";
            koordinatX = 37.8692; 
            koordinatY = 32.4844 
        },
        { 
            id = 3; 
            ad = "Karatay Durak Noktası"; 
            semtAdi = "Karatay";
            koordinatX = 37.8641; 
            koordinatY = 32.5011 
        }
    ];

    // Konya otobüs hatları
    let konyaOtobusleri : [OtobusHatti] = [
        {
            id = 1;
            hatAdi = "1 Numaralı Hat";
            baslangicDuragi = "Meram Terminal";
            bitisDuragi = "Selçuklu Transfer Merkezi";
            guzergah = [
                "Meram Terminal", 
                "Zafer Meydanı", 
                "Üniversite Kampüsü", 
                "Selçuklu Transfer Merkezi"
            ]
        },
        {
            id = 2;
            hatAdi = "2 Numaralı Hat";
            baslangicDuragi = "Karatay Durak Noktası";
            bitisDuragi = "Meram Terminal";
            guzergah = [
                "Karatay Durak Noktası",
                "Mevlana Müzesi",
                "Alaaddin Tepesi", 
                "Meram Terminal"
            ]
        }
    ];

    // Aktif otobüsler
    var aktifOtobusler : [Otobus] = [
        {
            id = 1;
            hatId = 1;
            plaka = "42 ABC 123";
            kapasite = 60;
            mevcutYolcuSayisi = 25;
            aktifDurak = "Meram Terminal"
        },
        {
            id = 2;
            hatId = 2;
            plaka = "42 DEF 456";
            kapasite = 50;
            mevcutYolcuSayisi = 30;
            aktifDurak = "Karatay Durak Noktası"
        }
    ];

    // Yeni otobüs hattı ekleme fonksiyonu
    public func yeniHatEkle(
        hatId : Nat, 
        hatAdi : Text, 
        baslangicDuragi : Text, 
        bitisDuragi : Text, 
        guzergah : [Text]
    ) : async Text {
        let yeniHat : OtobusHatti = {
            id = hatId;
            hatAdi = hatAdi;
            baslangicDuragi = baslangicDuragi;
            bitisDuragi = bitisDuragi;
            guzergah = guzergah
        };
        
        Debug.print("Yeni hat eklendi: " # hatAdi);
        return "Hat başarıyla eklendi";
    };

    // Otobüse yolcu bindirme fonksiyonu
    public func yolcuBindir(otobusId : Nat, yolcuSayisi : Nat) : async Text {
        for (otobus in aktifOtobusler.vals()) {
            if (otobus.id == otobusId) {
                if (otobus.mevcutYolcuSayisi + yolcuSayisi <= otobus.kapasite) {
                    Debug.print("Yolcular " # otobus.plaka # " plakalı otobüse bindirildi");
                    return "Yolcular başarıyla bindirildi";
                } else {
                    return "Otobüs kapasitesi yetersiz";
                }
            }
        };
        return "Otobüs bulunamadı";
    };

    // Otobüsün bir sonraki durağa geçmesi
    public func sonrakiDuragaGec(otobusId : Nat) : async Text {
        for (otobus in aktifOtobusler.vals()) {
            if (otobus.id == otobusId) {
                // Hat bilgisini bul
                for (hat in konyaOtobusleri.vals()) {
                    if (hat.id == otobus.hatId) {
                        // Şu anki durağın indexini bul
                        let mevcutDurakIndex = Array.find<Text>(hat.guzergah, func(d) = d == otobus.aktifDurak);
                        
                        switch (mevcutDurakIndex) {
                            case (?(index)) {
                                if (index + 1 < hat.guzergah.size()) {
                                    let sonrakiDurak = hat.guzergah[index + 1];
                                    Debug.print(otobus.plaka # " plakalı otobüs " # sonrakiDurak # " durağına geçti");
                                    return "Otobüs " # sonrakiDurak # " durağına geçti";
                                } else {
                                    return "Hat sonuna ulaşıldı";
                                }
                            };
                            case (null) {
                                return "Durak bulunamadı";
                            }
                        }
                    }
                }
            }
        };
        return "Otobüs bulunamadı";
    };

    // Toplam yolcu sayısını hesaplama
    public query func toplamYolcuSayisi() : async Nat {
        var toplam : Nat = 0;
        for (otobus in aktifOtobusler.vals()) {
            toplam += otobus.mevcutYolcuSayisi;
        };
        return toplam;
    };
}