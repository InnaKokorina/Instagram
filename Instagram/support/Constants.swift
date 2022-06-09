//
//  Constants.swift
//  Instagram
//
//  Created by Inna Kokorina on 11.04.2022.
//

import Foundation

struct Constants {
    struct Auth {
        static let createUser = "Создайте аккаунт"
        static let signIn = "Войдите в аккаунт"
        static let infoCreate = "Заполните данные в полях ниже, чтобы создать учетную запись"
        static let infoSignIn = "Войдите в систему, чтобы продолжить работу в приложении"
        static let switchButtonCreate = "Еще не с нами?"
        static let switchButtonSignIn = "Уже есть аккаунт?"
        static let placeholderPassword = "Введите пароль"
        static let placeholderEmail = "Введите Email"
        static let placeholderName = "Введите имя"
        static let backImageName = "backAuth"
        static let buttonTitle = "GO!"
    }

    struct Font {
        static let font = "Times New Roman"
    }

    struct App {
        static let title = "PhotoStory"
        static let titleComments = "Комментарии"
        static let titleMessages = "Сообщения"
    }

    struct ImagePicker {
        static let title = "Новая побликация"
        static let takePhoto = "Сделать фото"
        static let photoLib = "Выбрать фото"
        static let cancel = "Отмена"
        static let textPhotoPlaceholder = "Поделитесь впечатлением..."
        static let share = "Поделиться"
    }
    struct FStore {
        static let collectionName = "messages"
        static let user = "user"
        static let partner = "partner"
        static let bodyField = "body"
        static let dateField = "date"
    }
}
