defmodule Fracomex.Utilities do

  def get_page_title_tag(request_path, user_id) do
    uid = cond do
      not is_nil(user_id) -> user_id
      true -> ""
    end

    modif_mdp = "/modifier-motdepasse/#{uid}"
    modif_profil = "/modifier-profil/#{uid}"
    modif_adresse = "/modifier-adresse/#{uid}"

    case request_path do

      "/" -> "Eléctricité | Quincaillerie | Sanitaire"
      "/boutique" -> "Boutique"
      "/panier" -> "Panier"
      "/connexion" -> "Connexion"
      "/inscription" -> "Inscription"
      "/verification-confirmation-mail" -> "Vérification"
      "/verification-mdp-oublie" -> "Vérification"
      "/mdp-oublie" -> "Vérification"
      "/renvoi-verification-mail" -> "Vérification"
      "/mon-profil" -> "Mon profil"
      "/mon-adresse" -> "Mon adresse"
      "/valider-connexion" -> "Validation"
      "/valider-inscription" -> "Validation"
      "/envoi-mail-mdp-oublie" -> "Envoi"
      "/renvoi-mail-confirmation" -> "Envoi"
      modif_mdp -> "Modification"
      modif_profil -> "Modification"
      modif_adresse -> "Modification"
      _ -> "Fracomex"

    end

  end

end
